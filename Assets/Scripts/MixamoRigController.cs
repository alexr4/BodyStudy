using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

namespace Com.BonjourLab{
    public class MixamoRigController : MonoBehaviour
    {
        public List<Transform> mixamoRigList;
        private string riggtag = "MixamoRigg";
        private string meshtag = "MixamoMesh";
        public int offsetPerVert = 25;

        [HideInInspector]
        public List<List<Vector4>> mixamoRigPositionList    = new List<List<Vector4>>();
        public List<List<Vector3>> mixamoRig3PositionList    = new List<List<Vector3>>();
        public List<List<Vector4>> mixamoVertList           = new List<List<Vector4>>();
        public List<List<Vector4>> mixamoNormalList         = new List<List<Vector4>>();
        public List<List<Vector3>> mixamoVert3List          = new List<List<Vector3>>();
        public List<List<Vector3>> mixamoNormal3List        = new List<List<Vector3>>();
        

        //debug
        public bool showBonesGizmos = true;
        public bool showNormalsGizmos = true;
        public int normalOffset = 50;
        public bool showBound;

        private void Update(){
        // GetMixamoRiggFromTag();
        // GetMixamoVertListFromTag();
        }

        public void GetMixamoRiggFromTag(){
            mixamoRigPositionList.Clear();
            for(int i=0; i<mixamoRigList.Count; i++){
                List<Vector4> boneList = new List<Vector4>();
                GetMixamoRiggFromTag(mixamoRigList[i], i, boneList, riggtag);
                mixamoRigPositionList.Add(boneList);
            }
        }

        public void GetMixamoRigg3FromTag(){
            mixamoRig3PositionList.Clear();
            for(int i=0; i<mixamoRigList.Count; i++){
                List<Vector3> boneList = new List<Vector3>();
                GetMixamoRiggFromTag(mixamoRigList[i], i, boneList, riggtag);
                mixamoRig3PositionList.Add(boneList);
            }
        }

        private void GetMixamoRiggFromTag(Transform trs, int index, List<Vector4> boneList, string riggtag){
            for(int j=0; j<trs.childCount; j++){
                Transform child = trs.GetChild(j);
                if(child.tag == riggtag){
                    boneList.Add(new Vector4(child.position.x, child.position.y, child.position.z, index));
                }
                if(child.childCount > 0){
                    GetMixamoRiggFromTag(child, index, boneList, riggtag);
                }
            }
        }

        private void GetMixamoRiggFromTag(Transform trs, int index, List<Vector3> boneList, string riggtag){
            for(int j=0; j<trs.childCount; j++){
                Transform child = trs.GetChild(j);
                if(child.tag == riggtag){
                    boneList.Add(new Vector3(child.position.x, child.position.y, child.position.z));
                }
                if(child.childCount > 0){
                    GetMixamoRiggFromTag(child, index, boneList, riggtag);
                }
            }
        }

        public void GetMixamoVertListFromTag(){
            mixamoVertList.Clear();
            mixamoNormalList.Clear();
            for(int i=0; i<mixamoRigList.Count; i++){
                List<Vector4> vertList = new List<Vector4>();
                List<Vector4> normList = new List<Vector4>();
                GetMixamoVertListFromTag(mixamoRigList[i], i, vertList, normList, meshtag);
                mixamoVertList.Add(vertList);
                mixamoNormalList.Add(normList);
            }
        }

        public void GetMixamoVert3ListFromTag(){
            mixamoVert3List.Clear();
            mixamoNormal3List.Clear();
            for(int i=0; i<mixamoRigList.Count; i++){
                List<Vector3> vertList = new List<Vector3>();
                List<Vector3> normList = new List<Vector3>();
                GetMixamoVert3ListFromTag(mixamoRigList[i], i, vertList, normList, meshtag);
                mixamoVert3List.Add(vertList);
                mixamoNormal3List.Add(normList);
            }
        }

        private void GetMixamoVertListFromTag(Transform trs, int index, List<Vector4> vertList, List<Vector4> normList, string meshTag){
            for(int j=0; j<trs.childCount; j++){
                Transform child = trs.GetChild(j);
                if(child.tag == meshTag){
                    Mesh mesh = new Mesh();
                    SkinnedMeshRenderer skin = child.GetComponent<SkinnedMeshRenderer>();
                    skin.BakeMesh(mesh);
                    // mesh = skin.sharedMesh;
                    for(int i=0; i<mesh.vertices.Length; i+=offsetPerVert) {
                        Vector3 v = mesh.vertices[i];
                        Vector3 n = mesh.normals[i];
                        vertList.Add(new Vector4(v.x, v.y, v.z, index));
                        normList.Add(new Vector4(n.x, n.y, n.z, index));
                    }
                }
                if(child.childCount > 0){
                    GetMixamoVertListFromTag(child, index, vertList, normList, meshTag);
                }
            }
        }

        private void GetMixamoVert3ListFromTag(Transform trs, int index, List<Vector3> vertList, List<Vector3> normList, string meshTag){
            for(int j=0; j<trs.childCount; j++){
                Transform child = trs.GetChild(j);
                if(child.tag == meshTag){
                    Mesh mesh = new Mesh();
                    SkinnedMeshRenderer skin = child.GetComponent<SkinnedMeshRenderer>();
                    skin.BakeMesh(mesh);
                    vertList.AddRange(mesh.vertices);
                    normList.AddRange(mesh.normals);
                    // mesh = skin.sharedMesh;
                }
                if(child.childCount > 0){
                    GetMixamoVert3ListFromTag(child, index, vertList, normList, meshTag);
                }
            }
        }

        public List<Vector4> GetVertListAsOneList(){
            int size = 0;
            foreach(List<Vector4> _list in mixamoVertList){
                size += _list.Count;
            }

            List<Vector4> list = new List<Vector4>(size);

            foreach(List<Vector4> _list in mixamoVertList){
                list.AddRange(_list);
            }
            
            return list;
        }

        public Matrix4x4 GetTRS(int index){
            return Matrix4x4.TRS(
                                mixamoRigList[index].position,
                                mixamoRigList[index].rotation,
                                mixamoRigList[index].localScale);
        }

        public Vector3 GetPosition(int index){
            return mixamoRigList[index].position;
        }
        
        public Quaternion GetRotation(int index){
            return mixamoRigList[index].rotation;
        }

        public Vector3 GetLossyScale(int index){
            return mixamoRigList[index].lossyScale;
        }

        public Vector3 GetScale(int index){
            return mixamoRigList[index].localScale;
        }

        public TransformProperties GetTransformProperties(int index){
            TransformProperties props = new TransformProperties();
            Transform trs   = mixamoRigList[index];
            Vector3 gBounds = Vector3.zero;
            Vector3 gCenter = Vector3.zero;
            int count       = 0;
            for(int j=0; j<trs.childCount; j++){
                Transform child = trs.GetChild(j);
                if(child.tag == meshtag){
                    Mesh mesh = new Mesh();
                    SkinnedMeshRenderer skin    = child.GetComponent<SkinnedMeshRenderer>();
                    Bounds bounds               = skin.bounds;
                    gCenter                     += bounds.center;
                    count                       ++;
                    if(bounds.size.x > gBounds.x){
                        gBounds.x += bounds.size.x;
                    }
                    if(bounds.size.y > gBounds.y){
                        gBounds.y += bounds.size.y;
                    }
                    if(bounds.size.z > gBounds.z){
                        gBounds.z += bounds.size.z;
                    }
                }
            }
            gCenter /= count;

            props.gravityCenter = gCenter;
            props.size          = gBounds;

            return props;
        }


        private void OnDrawGizmos() { 
            if(showBonesGizmos){
                GetMixamoRiggFromTag();
                Gizmos.color = Color.green;
                foreach(List<Vector4> bonelist in mixamoRigPositionList){
                    foreach(Vector4 bone in bonelist){
                        Gizmos.DrawSphere(new Vector3(bone.x, bone.y, bone.z), .025f);
                    }
                }
            }

            if(showNormalsGizmos)
            {
                GetMixamoVert3ListFromTag();
                Gizmos.color = Color.blue;
                for(int j=0; j<mixamoVert3List.Count; j++){
                    List<Vector3> vertlist  = mixamoVert3List[j];
                    List<Vector3> normList  = mixamoNormal3List[j];
                    Transform tr            = mixamoRigList[j];
                    for(int i=0; i<vertlist.Count; i+=normalOffset){
                        Vector3 v = new Vector3(vertlist[i].x, vertlist[i].y, vertlist[i].z);
                        Vector3 n = new Vector3(normList[i].x, normList[i].y, normList[i].z);
                        Gizmos.DrawLine(tr.position+v, tr.position + v + n * 0.05f);
                    }
                }
            }

            if(showBound){
                Gizmos.color = Color.red;
                foreach(Transform trs in mixamoRigList){
                    Vector3 gBounds = Vector3.zero;
                    Vector3 gCenter = Vector3.zero;
                    int count       = 0;
                    for(int j=0; j<trs.childCount; j++){
                        Transform child = trs.GetChild(j);
                        if(child.tag == meshtag){
                            Mesh mesh = new Mesh();
                            SkinnedMeshRenderer skin    = child.GetComponent<SkinnedMeshRenderer>();
                            Bounds bounds               = skin.bounds;
                            gCenter                     += bounds.center;
                            count                       ++;
                            if(bounds.size.x > gBounds.x){
                                gBounds.x += bounds.size.x;
                            }
                            if(bounds.size.y > gBounds.y){
                                gBounds.y += bounds.size.y;
                            }
                            if(bounds.size.z > gBounds.z){
                                gBounds.z += bounds.size.z;
                            }
                        }
                    }
                    gCenter /= count;
                    Gizmos.DrawWireCube(gCenter, gBounds);
                }
            }
            
        }
    }
}
