using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab
{
    public class BodyStudy29 : GPUMeshController
    {
        
        public Texture2D bodyramp;
        
        public float minOffset;
        public float maxOffset;

        public override void SetBasedInstanceData(){
            MeshPropertiesPhysics[] properties = new MeshPropertiesPhysics[maxInstance];

            for(int i=0; i<maxInstance; i++){
                MeshPropertiesPhysics props    = new MeshPropertiesPhysics();

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
                props.opos              = new Vector4(position.x, position.y, position.z, Random.value);
                props.vel               = new Vector4(0, 0, 0, 0);
                props.acc               = new Vector4(0, 0, 0, 0);
                props.data              = new Vector4(index, 0, 0, Random.value); //x → index, y → Free, z → Free, w → Free

                properties[i] = props;
            }

            meshPropertiesBuffer = new ComputeBuffer(maxInstance, MeshPropertiesPhysics.Size());
            meshPropertiesBuffer.SetData(properties);
        }

        public override void BindBasedDataToComputeShader(){
            Bounds bounds       = mesh.bounds;
            float maxSize       = bounds.extents.y;

            base.BindBasedDataToComputeShader();
            compute.SetTexture(kernel, "_BodyRamp", bodyramp);
            compute.SetVector("_RampSize", new Vector2(bodyramp.width, bodyramp.height));
            compute.SetFloat("_MaxInstance", maxInstance);
            compute.SetFloat("_MaxSize", maxSize);
        }

         public override void BindUpdatedDataToComputeShader(){
            base.BindUpdatedDataToComputeShader();
            compute.SetFloat("_DeltaTime", Time.deltaTime);
            compute.SetFloat("_MinOffset", minOffset);
            compute.SetFloat("_MaxOffset", maxOffset);
        }

    }
}
