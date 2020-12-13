using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab
{
    public class BodyStudy09 : GPUMeshController
    {
        public Vector3 wind;

       public override void SetBasedInstanceData(){
            MeshPropertiesExtended[] properties = new MeshPropertiesExtended[maxInstance];

            for(int i=0; i<maxInstance; i++){
                MeshPropertiesExtended props    = new MeshPropertiesExtended();

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
                props.opos              = new Vector4(position.x, position.y, position.z);
                props.data              = new Vector4(index, 0, 0, Random.value); //x → index, y → Free, z → Free, w → Free

                properties[i] = props;
            }

            meshPropertiesBuffer = new ComputeBuffer(maxInstance, MeshPropertiesExtended.Size());
            meshPropertiesBuffer.SetData(properties);
        }

        public override void BindUpdatedDataToComputeShader(){
            base.BindUpdatedDataToComputeShader();
            compute.SetVector("_Wind", wind);
       }
    }
}
