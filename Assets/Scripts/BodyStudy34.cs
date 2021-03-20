using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab
{
    public class BodyStudy34 : GPUMeshController
    {

        public Vector3 wind;
        public Texture2D bodyramp;
        
        public float minOffset;
        public float maxOffset;
        public float offsety;
        [Range(-1, 1)] public float dotOffset;
        [Range(0, 0.5f)] public float randomCellRange;

        private float res;
        private int divider;

        [Header("Voxel Params")]
        public float resolution;
        public struct CRD
        {
            public int width;
            public int height;
            public int depth;
        }
        CRD crd;

        protected override void SetArgumentBuffer(){
            crd         = new CRD();
            crd.width   = Mathf.RoundToInt(world.x / resolution);
            crd.height  = Mathf.RoundToInt(world.y / resolution);
            crd.depth   = Mathf.RoundToInt(world.z / resolution);

            maxInstance = crd.width * crd.height * crd.depth;
            Debug.Log(crd.width +"::"+ crd.height +"::"+ crd.depth+" :: "+world);

            base.SetArgumentBuffer();
        }

        public override void SetBasedInstanceData(){
            MeshPropertiesExtended[] properties = new MeshPropertiesExtended[maxInstance];

            // divider         = Mathf.CeilToInt(Mathf.Pow(maxInstance, 1.0f/3.0f));
            // res             = (1.0f/divider);
            // Vector3 cell    = new Vector3(res, res, res);

            for(int i=0; i<maxInstance; i++){
                MeshPropertiesExtended props    = new MeshPropertiesExtended();

                float normi             = (float) i/(float)maxInstance;
                float indexSamp         = (isRand) ? Random.value : normi;

                int index               = Mathf.FloorToInt(indexSamp * (posList.Count - 1)); 
                // Vector3 cellPos = new Vector3(  i/(divider * divider),
                //                                 (i/divider) % divider,
                //                                 i % divider);
                
                // Vector3 normPosition    = cellPos / divider + cell * 0.5f;
                // normPosition            += new Vector3( cell.x * Random.Range(-randomCellRange, randomCellRange), 
                //                                         cell.y * Random.Range(-randomCellRange, randomCellRange), 
                //                                         cell.z * Random.Range(-randomCellRange, randomCellRange));

                // normPosition            = normPosition * 2.0f - Vector3.one;
                // Vector3 position        = new Vector3(  normPosition.x * world.x * 0.5f,
                //                                         normPosition.y * world.y * 0.5f, 
                //                                         normPosition.z * world.z * 0.5f) + toGravityCenter;

                int zi                  = i / ((crd.width) * (crd.height));
                int ni                  = i - (zi * (crd.width) * (crd.height));
                int yi                  = ni / (crd.width);
                int xi                  = ni % (crd.width);
                
                //add some jittering
                Vector3 position        = new Vector3(
                    xi * resolution - world.x * 0.5f + resolution * 0.5f,
                    yi * resolution - world.y * 0.5f + resolution * 0.5f,
                    zi * resolution - world.z * 0.5f + resolution * 0.5f
                );

                position += toGravityCenter;

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
                
                Vector3 scale           = /*Random.Range(this.minScale, this.maxScale)*/ (resolution * 0.75f) * modelDescription;
                
                props.trmat             = Matrix4x4.Translate(position);
                props.rotmat            = Matrix4x4.Rotate(rotation);
                props.scmat             = Matrix4x4.Scale(scale);
                props.oscmat            = Matrix4x4.Scale(scale);
                props.color             = Color.Lerp(color0, color1, Random.value);
                props.opos              = new Vector4(position.x, position.y, position.z);
                props.data              = new Vector4(i, 0, 0, Random.value); //x → index, y → Free, z → Free, w → Free

                properties[i] = props;
            }

            meshPropertiesBuffer = new ComputeBuffer(maxInstance, MeshPropertiesExtended.Size());
            meshPropertiesBuffer.SetData(properties);
        }

        public override void BindBasedDataToComputeShader(){
            Bounds bounds       = mesh.bounds;
            float maxSize       = bounds.extents.y;

            base.BindBasedDataToComputeShader();
            compute.SetTexture(kernel, "_BodyRamp", bodyramp);
            compute.SetVector("_RampSize", new Vector2(bodyramp.width, bodyramp.height));
            compute.SetFloat("_Resolution", res);
            compute.SetInt("_CellRes", divider);
            compute.SetVector("_Offset", toGravityCenter);
            compute.SetVector("_CRD", new Vector3(crd.width, crd.height, crd.depth));
        }

        public override void BindUpdatedDataToComputeShader(){
            base.BindUpdatedDataToComputeShader();
            compute.SetVector("_Wind", wind);
            compute.SetFloat("_MinOffset", minOffset);
            compute.SetFloat("_MaxOffset", maxOffset);
            compute.SetFloat("_OffsetY", offsety);
            compute.SetFloat("_DotdOffset", dotOffset);
       }
    }
}
