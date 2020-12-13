#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
StructuredBuffer<MeshPropertiesPhysisc> _Properties;
#endif

/** When redefining the unity_ObjectToWorld Matrix, its inverse is not redefine, which produce an error in the lighting
https://forum.unity.com/threads/trying-to-rotate-instances-with-drawmeshinstancedindirect-shader-but-the-normals-get-messed-up.707600/
*/
float4x4 inverse(float4x4 input)
{
    #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
    float4x4 cofactors = float4x4(
        minor(_22_23_24, _32_33_34, _42_43_44),
        -minor(_21_23_24, _31_33_34, _41_43_44),
        minor(_21_22_24, _31_32_34, _41_42_44),
        -minor(_21_22_23, _31_32_33, _41_42_43),
        -minor(_12_13_14, _32_33_34, _42_43_44),
        minor(_11_13_14, _31_33_34, _41_43_44),
        -minor(_11_12_14, _31_32_34, _41_42_44),
        minor(_11_12_13, _31_32_33, _41_42_43),
        minor(_12_13_14, _22_23_24, _42_43_44),
        -minor(_11_13_14, _21_23_24, _41_43_44),
        minor(_11_12_14, _21_22_24, _41_42_44),
        -minor(_11_12_13, _21_22_23, _41_42_43),
        -minor(_12_13_14, _22_23_24, _32_33_34),
        minor(_11_13_14, _21_23_24, _31_33_34),
        -minor(_11_12_14, _21_22_24, _31_32_34),
        minor(_11_12_13, _21_22_23, _31_32_33)
        );
    #undef minor
    return transpose(cofactors) / determinant(input);
}

void setup(){
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesPhysisc props = _Properties[unity_InstanceID];
    unity_ObjectToWorld = mul(props.trmat, mul(props.rotmat, props.scmat));
    unity_WorldToObject = inverse(unity_ObjectToWorld);
    #endif
}

#define PI 3.14159265359
float3 CartesianToSpherical(float3 vertex){
    float r     = length(vertex);
    float alpha = atan(vertex.y / vertex.z) + PI * 0.5; //-PI*0.5 | PI * 0.5
    float phi   = atan(sqrt(vertex.x * vertex.x + vertex.y * vertex.x)/vertex.z) + PI * 0.5;

    return float3(r, alpha, phi);
}

float3 SphericalToCartesian(float3 spherical){
    float x = spherical.x * sin(spherical.y) * cos(spherical.z);
    float y = spherical.x * sin(spherical.y) * sin(spherical.z);
    float z = spherical.x * cos(spherical.y);

    return float3(x, y, z);
}

void vertex(inout appdata_full v, out Input o){
    UNITY_INITIALIZE_OUTPUT(Input, o);
    o.pos = float4(0, 0, 0, 0);
    
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesPhysisc props = _Properties[unity_InstanceID];
    o.id    = float(unity_InstanceID);
    o.color = props.color;
    o.data  = props.data;
    o.pos  = props.opos;
    #endif
    
    float scaleUV       = 2.5f;

    float3 vert         = v.vertex.xyz;
    // float3 sphCoord     = CartesianToSpherical(vert);
    // float3 neiTan       = SphericalToCartesian(sphCoord + float3(0, 0.01, 0));
    // float3 neiBiTan     = SphericalToCartesian(sphCoord + float3(0, 0, 0.01));

    float vertnoise     = noise(vert * scaleUV + _Time.y * 0.25);
    // float tannoise      = noise(neiTan * scaleUV + _Time.y * 0.25);
    // float bitannoise    = noise(neiBiTan * scaleUV + _Time.y * 0.25);

    float factor            = 0.25;
    float3 vertDisplace     = v.vertex.xyz + v.normal * vertnoise * factor;
    // float3 tanDisplace      = neiTan + normalize(neiTan) * tannoise * factor;
    // float3 bitanDisplace    = neiBiTan + normalize(neiBiTan) * bitannoise * factor;

    // float3 tangent          = tanDisplace - vertDisplace;
    // float3 bitangent        = bitanDisplace - vertDisplace;

    // float3 normal           = normalize(cross(tangent, bitangent));

    v.vertex.xyz    = vertDisplace.xyz;
    // v.normal.xyz    = normal; //normal computation from : https://discourse.threejs.org/t/calculating-vertex-normals-after-displacement-in-the-vertex-shader/16989 is not working
}