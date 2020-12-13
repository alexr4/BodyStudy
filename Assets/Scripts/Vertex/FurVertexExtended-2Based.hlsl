#include "Assets/Scripts/Utils/noises.hlsl"
#include "Assets/Scripts/Utils/easing.hlsl"

struct Input
{
    float2  uv_MainTex;
    float2  uv_BumpMap;
    float4  color;
    float4  data;
    float   id;
    float4  pos;
    float4 screenPos;
    float3 worldRefl;
    INTERNAL_DATA
    float3 viewDir;
};

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
StructuredBuffer<MeshPropertiesExtended> _Properties;
#endif

fixed4 _Color;
sampler2D _MainTex;
float2 _Tiles;
float2 _TilesFur;
half _Glossiness;
half _Metallic;

samplerCUBE _Cube;
half _EnviroBlur;
float _GlobalEmission;
float _AlbedoEmission;

uniform float _FurLength;
uniform float _Cutoff;
uniform float _CutoffEnd;
uniform float _EdgeFade;
uniform float _SmoothThick;
uniform float _BaseCutOff;
uniform float _BaseThickness;

uniform fixed3 _Gravity;
uniform float _GravityStrength;
uniform sampler2D _GravityTex;
uniform float4 _GravityTex_ST;
uniform float _GravityTexStrength;
uniform float _VelStrength;

uniform float _UvMultiplier;
uniform float _PosMultiplier;
uniform float _timeMultiplier;

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
    MeshPropertiesExtended props = _Properties[unity_InstanceID];
    unity_ObjectToWorld = mul(props.trmat, mul(props.rotmat, props.scmat));
    unity_WorldToObject = inverse(unity_ObjectToWorld);
    #endif
}

void vertex(inout appdata_full v, out Input o){
    UNITY_INITIALIZE_OUTPUT(Input, o);

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesExtended props = _Properties[unity_InstanceID];
    o.color = props.color;
    o.id    = float(unity_InstanceID);
    o.data  = props.data;
    o.pos  = props.opos;
    #endif
}