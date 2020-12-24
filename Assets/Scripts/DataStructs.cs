using UnityEngine;

namespace Com.BonjourLab{
    public struct MeshProperties{
        public UnityEngine.Matrix4x4 trmat;
        public UnityEngine.Matrix4x4 rotmat;
        public UnityEngine.Matrix4x4 scmat;
        public UnityEngine.Matrix4x4 oscmat;
        public UnityEngine.Vector4 data;
        public UnityEngine.Vector4 color;
        public static int Size(){
            return
                sizeof(float) * 4 * 4 + //translation matrix
                sizeof(float) * 4 * 4 + //rotation matrix
                sizeof(float) * 4 * 4 + //scale matrix
                sizeof(float) * 4 * 4 + //oscale matrix
                sizeof(float) * 4 + // data
                sizeof(float) * 4; // colors
        }
    }

    public struct MeshPropertiesExtended{
        public UnityEngine.Matrix4x4 trmat;
        public UnityEngine.Matrix4x4 rotmat;
        public UnityEngine.Matrix4x4 scmat;
        public UnityEngine.Matrix4x4 oscmat;
        public UnityEngine.Vector4 opos;
        public UnityEngine.Vector4 data;
        public UnityEngine.Vector4 color;
        public static int Size(){
            return
                sizeof(float) * 4 * 4 + //translation matrix
                sizeof(float) * 4 * 4 + //rotation matrix
                sizeof(float) * 4 * 4 + //scale matrix
                sizeof(float) * 4 * 4 + //oscale matrix
                sizeof(float) * 4 + // opos
                sizeof(float) * 4 + // data
                sizeof(float) * 4; // colors
        }
    }

    public struct MeshPropertiesPhysics{
        public UnityEngine.Matrix4x4 trmat;
        public UnityEngine.Matrix4x4 rotmat;
        public UnityEngine.Matrix4x4 scmat;
        public UnityEngine.Matrix4x4 oscmat;
        public UnityEngine.Vector4 opos;
        public UnityEngine.Vector4 vel;
        public UnityEngine.Vector4 acc;
        public UnityEngine.Vector4 data;
        public UnityEngine.Vector4 color;
        public static int Size(){
            return
                sizeof(float) * 4 * 4 + //translation matrix
                sizeof(float) * 4 * 4 + //rotation matrix
                sizeof(float) * 4 * 4 + //scale matrix
                sizeof(float) * 4 * 4 + //oscale matrix
                sizeof(float) * 4 + // opos
                sizeof(float) * 4 + // vel
                sizeof(float) * 4 + // acc
                sizeof(float) * 4 + // data
                sizeof(float) * 4; // colors
        }
    }

    public struct TransformProperties{
        public UnityEngine.Vector3 gravityCenter;
        public UnityEngine.Vector3 size;
        public static int Size(){
            return
                sizeof(float) * 3 +
                sizeof(float) * 3;
        }
    }
}