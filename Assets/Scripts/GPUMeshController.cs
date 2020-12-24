using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab{
    public class GPUMeshController : MonoBehaviour
    {
        [Header("Instance params")]
        [Tooltip("Define the number of instances")]
        public int maxInstance;
        public Vector3 world = new Vector3(1, 1, 1);

        [Tooltip("Define the based mesh used for instances")]
        public Mesh mesh;

         [Tooltip("Defines if the position is defined by taking a random vector from the skinned mesh or use ordered index")]
        public bool isRand = false;

        [Tooltip("Defines the minimum scale multiplier")]
        public float minScale;

        [Tooltip("Defines the maximum scale multiplier")]
        public float maxScale;

        [Tooltip("Defines the scale as a vector (X, Y, Z")]
        public Vector3 modelDescription;
        
        [Tooltip("Defines the max random rotation range which is form -180 * X to 180 * X")]
        [Range(0f,1f)] public float maxRndRotation;
        
        [Tooltip("Defines if the instances oriented following the normals of the SkinnedMesh")]
        public bool useNormalDirection = true;

        [Tooltip("Defines the instance material")]
        public Material material;
        
        [Tooltip("Defines the random color range instance")]
        public Color color0, color1;

        /*
        The following parameteres are used for the GPU instance and Compute shaders
        */
        protected ComputeBuffer meshPropertiesBuffer;
        protected ComputeBuffer argsBuffer;
        protected ComputeBuffer posBuffer;

        [HideInInspector] 
        public List<Vector3> posList;
        [HideInInspector] 
        public List<Vector3> normList;
        
        [Header("Compute Shader params")]
        public ComputeShader compute;
        protected int kernel;
        protected Bounds bounds;

        //Global variable for management
        protected int init = -1;
        /**
        init is a three state value -1: not set, 0: false, 1: true
        Thoses three steps helps manage Disable/Enable activity to rinit Compute Shader and buffer when calling SetActive(true/false)
        whithout returning en error at Start (OnEnable called only after Awake)
        */
        protected float savedTime;

        //Decomposed TRS from based mesh
        [HideInInspector] public Transform refTransform;
        [HideInInspector] public TransformProperties trsProperties;
        protected Vector3 toGravityCenter;

        public void Initialize(){
            // Boundary surrounding the meshes we will be drawing.  Used for occlusion.
            bounds = new Bounds(transform.position, world);
            //init all the buffers
            InitializeBuffers();
            // Set the state of the buffer to 1 (initialized)
            init = 1;
        }

        protected void InitializeBuffers(){
            //Instantiate Compute and Material shaders in order to use them multiple time
            compute = Instantiate(compute);
            material = Instantiate(material);

            //Get the Main function from your Compute shader
            kernel = compute.FindKernel("CSMain");

            //Argument buffer used by DrawMeshInstanceIndirect
            uint[] args = new uint[5]{0, 0, 0, 0, 0};
            //arguments for drawing mesh
            //0 = number of triangle indices, 1 = maxInstance, other are obly relevant for drawing submeshes
            args[0] = (uint) mesh.GetIndexCount(0);
            args[1] = (uint) maxInstance;
            args[2] = (uint) mesh.GetIndexStart(0);
            args[3] = (uint) mesh.GetBaseVertex(0);

            argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
            argsBuffer.SetData(args);
            
            // scale modeldesc to ref world TRS
            modelDescription = new Vector3( modelDescription.x * refTransform.lossyScale.x,
                                            modelDescription.y * refTransform.lossyScale.y,
                                            modelDescription.z * refTransform.lossyScale.z);

            // scale world to fit model
            world           = new Vector3(  world.x * trsProperties.size.x,
                                            world.y * trsProperties.size.y,
                                            world.z * trsProperties.size.z); 

            //get local transform to gravity center
            toGravityCenter = trsProperties.gravityCenter - transform.position;

            SetBasedInstanceData(); //Set based data for instance
            
            compute.SetBuffer(kernel, "_Properties", meshPropertiesBuffer); //Bind properties buffer to Compute Shader
            material.SetBuffer("_Properties", meshPropertiesBuffer); //Bind Properties buffer Directly to the material (GPU communication)
            material.SetVector("_World", world);
            
            BindBasedDataToComputeShader(); //Bind global variable to Compute Shader
            BindUpdatedDataToComputeShader();//Bind first update of real time datas
        }

        public virtual void SetBasedInstanceData(){
            MeshProperties[] properties = new MeshProperties[maxInstance];

            for(int i=0; i<maxInstance; i++){
                MeshProperties props    = new MeshProperties();

                float normi             = (float) i/(float)maxInstance;
                float indexSamp         = (isRand) ? Random.value : normi;

                int index               = Mathf.FloorToInt(indexSamp * (posList.Count - 1)); 
                Vector3 position        = posList[index];
                Vector3 normal          = normList[index];
                Vector3 target          = position + normList[index];
                Vector3 look            = (target - position).normalized;

                Quaternion rotation     = Quaternion.identity;
                if(useNormalDirection){
                    rotation            = Quaternion.LookRotation(look, Vector3.up);
                    rotation            *= Quaternion.Euler(Vector3.right * 90.0f);
                }

                if(maxRndRotation > 0){
                    Quaternion rndRat   = Quaternion.Euler(Random.Range(-180, 180) * maxRndRotation, Random.Range(-180, 180) * maxRndRotation, Random.Range(-180, 180) * maxRndRotation);
                    rotation *= rndRat;
                }
                
                Vector3 scale           = Random.Range(this.minScale, this.maxScale) * modelDescription;
                
                props.trmat             = Matrix4x4.Translate(position);
                props.rotmat            = Matrix4x4.Rotate(rotation);
                props.scmat             = Matrix4x4.Scale(scale);
                props.oscmat            = Matrix4x4.Scale(scale);
                props.color             = Color.Lerp(color0, color1, Random.value);
                props.data              = new Vector4(index, 0, 0, Random.value); //x → index, y → Free, z → Free, w → Free

                properties[i] = props;
            }

            meshPropertiesBuffer = new ComputeBuffer(maxInstance, MeshProperties.Size());
            meshPropertiesBuffer.SetData(properties);
        }

        public virtual void BindBasedDataToComputeShader(){
            savedTime   = Time.fixedTime;
            compute.SetVector("_World", world); 
        }

        public virtual void BindUpdatedDataToComputeShader(){
            compute.SetFloat("_Time", Time.fixedTime - savedTime);
            compute.SetFloat("_MaxScale", maxScale);
            compute.SetFloat("_MinScale", minScale);
            compute.SetVector("_ModelDescription", modelDescription);
        }

        public void Compute() {
            BindUpdatedDataToComputeShader();
            compute.Dispatch(kernel, Mathf.CeilToInt(maxInstance/64f), 1, 1);
            Graphics.DrawMeshInstancedIndirect(mesh, 0, material, bounds, argsBuffer);
        }

        protected void OnDrawGizmos() {
            Gizmos.color = Color.green;
            Gizmos.DrawWireCube(transform.position + toGravityCenter, world);
        }

        private void OnDisable() {
            //released everything
            if(meshPropertiesBuffer != null){
                meshPropertiesBuffer.Release();
            }
            meshPropertiesBuffer = null;

            if(argsBuffer != null){
                argsBuffer.Release();
            }

            argsBuffer = null;

            if(posBuffer != null){
                posBuffer.Release();
            }
            posBuffer = null;

            init = 0;
        }

        private void OnEnable(){
            if(init == 0){
                Initialize();
            }
        }

        public void BindVectorArray(List<Vector3> vectorArray){
            if(posBuffer == null){
                posBuffer = new ComputeBuffer(vectorArray.Count, sizeof(float) * 3);
                posBuffer.SetData(vectorArray);
                compute.SetBuffer(kernel, "_Position", posBuffer);
                compute.SetInt("_PositionCount", vectorArray.Count);
            }else{
                posBuffer.SetData(vectorArray);
            }
        }

        public void BindVectorArray(List<Vector4> vectorArray){ //G
            if(posBuffer == null){
                posBuffer = new ComputeBuffer(vectorArray.Count, sizeof(float) * 4);
                posBuffer.SetData(vectorArray);
                compute.SetBuffer(kernel, "_Position", posBuffer);
                compute.SetInt("_PositionCount", vectorArray.Count);
            }else{
                posBuffer.SetData(vectorArray);
            }
        }

        public void BindTRS(Matrix4x4 TRS){
            compute.SetMatrix("_TRS", TRS);
        }
    }
}