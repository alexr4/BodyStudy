using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    private Camera reflectionCamera;
    private Camera cameraReference;

    public GameObject reflectionPlane;

    RenderTexture targetTexture;
    public Material floorMaterial;
    // [Range(0f, 1f)] public float reflectionFactor;
    // [Range(0f, 1f)] public float reflectionPower;


    void Start()
    {
        GameObject reflectionCameraGO   = new GameObject("Reflection Camera");
        reflectionCamera                = reflectionCameraGO.AddComponent<Camera>();
        reflectionCamera.enabled        = false;

        cameraReference                 = Camera.main;     

        targetTexture                   = new RenderTexture(Screen.width, Screen.height, 24);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void RenderReflection(){
        reflectionCamera.CopyFrom(cameraReference);

        Vector3 cameraDirectionWorldSpace   = cameraReference.transform.forward;
        Vector3 cameraUpWorldSpace          = cameraReference.transform.up;
        Vector3 cameraPositionWorldSpace    = cameraReference.transform.position;

        //Transform the vectors to the floor's space
        Vector3 cameraDirectionPlaneSpace   = reflectionPlane.transform.InverseTransformDirection(cameraDirectionWorldSpace);
        Vector3 cameraUpPlaneSpace          = reflectionPlane.transform.InverseTransformDirection(cameraUpWorldSpace);
        Vector3 cameraPositionPlaneSpace    = reflectionPlane.transform.InverseTransformPoint(cameraPositionWorldSpace);

        //Mirror the Vectors
        cameraDirectionPlaneSpace.y         *= -1.0f;
        cameraUpPlaneSpace.y                *= -1.0f;
        cameraPositionPlaneSpace.y          *= -1.0f;

        //Transform the vectors back to world space
        cameraDirectionWorldSpace           = reflectionPlane.transform.TransformDirection(cameraDirectionPlaneSpace);
        cameraUpWorldSpace                  = reflectionPlane.transform.TransformDirection(cameraUpPlaneSpace);
        cameraPositionWorldSpace            = reflectionPlane.transform.TransformPoint(cameraPositionPlaneSpace);

        //set camera position and rotation
        reflectionCamera.transform.position = cameraPositionWorldSpace;
        reflectionCamera.transform.LookAt(cameraPositionWorldSpace + cameraDirectionWorldSpace, cameraUpWorldSpace);

        //set the render texture
        reflectionCamera.targetTexture      = targetTexture;

        //call the render
        reflectionCamera.Render();

        floorMaterial.SetTexture("_ReflectionTex", targetTexture);
        // floorMaterial.SetFloat("_ReflectionFactor", reflectionFactor);
        // floorMaterial.SetFloat("_RelfectionPower", reflectionPower);

    }

    private void OnPreRender(){
        RenderReflection();
    }
}
