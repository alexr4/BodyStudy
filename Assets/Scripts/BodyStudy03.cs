using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab
{
    public class BodyStudy03 : GPUMeshController
    {
       public Vector3 wind;

       public override void BindUpdatedDataToComputeShader(){
            base.BindUpdatedDataToComputeShader();
            compute.SetVector("_Wind", wind);
       }
    }
}
