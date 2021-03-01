using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Com.BonjourLab{
    public class Controller : MonoBehaviour
    {
        [Tooltip("Defines if you want to retreives the Bonez or the Vertices of your reference SkinnedMesh")]
        public bool isMesh = true;

        [Tooltip("Push updated tangents to the compute shader")]
        public bool bindTangents = false;

        [Tooltip("Push updated normals to the compute shader")]
        public bool bindNormals = false;
        // private GPUMeshController_1130[] foundGPUMeshControllers;

        private MixamoRigController mixamoRigController;
        private GPUMeshController[] gpuMeshController;

        private void Awake(){
            mixamoRigController     = this.GetComponent<MixamoRigController>();
            gpuMeshController       = this.GetComponents<GPUMeshController>();

            Debug.Log(
                "Found MixamoRigController: "+mixamoRigController+
                "Found "+gpuMeshController.Length+" GPUMeshController"
            );
        }

        void Start()
        {
            if(isMesh){
                InitWithVertice();
            }else{
                InitWithRigg();
            }
        }

        void Update()
        {
            if(isMesh){
                UpdateWithVertice();
            }else{
                UpdateWithRigg();
            }
        }

        private void InitWithVertice(){
            mixamoRigController.GetMixamoVert3ListFromTag();

             for(int i=0; i<gpuMeshController.Length; i++){
                GPUMeshController gpumeshcontrolleri = gpuMeshController[i];
                gpumeshcontrolleri.posList           = mixamoRigController.mixamoVert3List[0];
                gpumeshcontrolleri.normList          = mixamoRigController.mixamoNormal3List[0];
                gpumeshcontrolleri.refTransform      = mixamoRigController.mixamoRigList[0];
                gpumeshcontrolleri.trsProperties     = mixamoRigController.GetTransformProperties(0);

                gpumeshcontrolleri.Initialize();
                gpumeshcontrolleri.BindVectorArray(mixamoRigController.mixamoVert3List[0]);
                
                if(bindTangents) gpumeshcontrolleri.BindTanArray(mixamoRigController.mixamoTangent4List[0]);
                if(bindNormals) gpumeshcontrolleri.BindNormArray(mixamoRigController.mixamoNormal3List[0]);

                gpumeshcontrolleri.BindTRS(mixamoRigController.GetTRS(0));
                gpumeshcontrolleri.Compute();
            }
        }

        private void InitWithRigg(){
            mixamoRigController.GetMixamoRigg3FromTag();
            for(int i=0; i<gpuMeshController.Length; i++){
                GPUMeshController gpumeshcontrolleri    = gpuMeshController[i];
                gpumeshcontrolleri.maxInstance          = mixamoRigController.mixamoRig3PositionList[0].Count;
                gpumeshcontrolleri.posList              = mixamoRigController.mixamoRig3PositionList[0];
                gpumeshcontrolleri.normList             = mixamoRigController.mixamoRig3PositionList[0];
                gpumeshcontrolleri.refTransform         = mixamoRigController.mixamoRigList[0];
                gpumeshcontrolleri.trsProperties        = mixamoRigController.GetTransformProperties(0);

                gpumeshcontrolleri.Initialize();
                gpumeshcontrolleri.BindVectorArray(mixamoRigController.mixamoRig3PositionList[0]);
                gpumeshcontrolleri.BindTRS(mixamoRigController.GetTRS(0));
                gpumeshcontrolleri.Compute();
            }
        }

        private void UpdateWithVertice(){
            mixamoRigController.GetMixamoVert3ListFromTag();
             for(int i=0; i<gpuMeshController.Length; i++){
                GPUMeshController gpumeshcontrolleri = gpuMeshController[i];
                gpumeshcontrolleri.BindVectorArray(mixamoRigController.mixamoVert3List[0]);

                if(bindTangents) gpumeshcontrolleri.BindTanArray(mixamoRigController.mixamoTangent4List[0]);
                if(bindNormals) gpumeshcontrolleri.BindNormArray(mixamoRigController.mixamoNormal3List[0]);

                gpumeshcontrolleri.BindTRS(mixamoRigController.GetTRS(0));
                gpumeshcontrolleri.Compute();
             }
        }

        private void UpdateWithRigg(){
            mixamoRigController.GetMixamoRigg3FromTag();
            for(int i=0; i<gpuMeshController.Length; i++){
                GPUMeshController gpumeshcontrolleri = gpuMeshController[i];
                gpumeshcontrolleri.BindVectorArray(mixamoRigController.mixamoRig3PositionList[0]);


                gpumeshcontrolleri.BindTRS(mixamoRigController.GetTRS(0));
                gpumeshcontrolleri.Compute();
            }
        }
    }
}
