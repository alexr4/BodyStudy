
#include "Assets/Scripts/Utils/noises.hlsl"
#include "Assets/Scripts/Utils/easing.hlsl"

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
StructuredBuffer<MeshPropertiesExtended> _Properties;
#endif

fixed4 _Color;
sampler2D _MainTex;
sampler2D _Ramp;
float2 _Tiles;
float2 _TilesFur;
half _Glossiness;
sampler2D _Metallic;
samplerCUBE _Cube;
uniform float _GlobalEmission;
uniform float _EnviroBlur;
uniform float _AlbedoEmission;

sampler2D _FurTex;
uniform float4 _FurTex_ST;
uniform float _FurLength;
uniform float _Cutoff;
uniform float _CutoffEnd;
uniform float _EdgeFade;
uniform float _SmoothThick;
uniform float _BaseCutOff;
uniform float _BaseThickness;
uniform float _NoiseFurBased;
uniform float _NoiseFurThick;
uniform float _NoiseFurSmooth;
uniform float3 _World;

uniform fixed3 _Gravity;
uniform float _GravityStrength;
uniform sampler2D _GravityTex;
uniform float4 _GravityTex_ST;
uniform float _GravityTexStrength;
uniform float _VelStrength;

uniform float _UvMultiplier;
uniform float _PosMultiplier;
uniform float _timeMultiplier;
uniform float _CutOut;

uniform float _LightThick;
uniform float _LightSmooth;

struct Input{
    float2 uv_MainTex;
    float2 uv_BumpMap;
    float3 viewDir;
    float4 color;
    float id;
    float4 data;
    float4 pos;
    float noiseLength;
    float4 screenPos;
    float3 worldRefl;
    INTERNAL_DATA
};

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

    float3 vel  = float3(0, 0, 0);
    float3 ipos = float3(0, 0, 0);
    o.color     = float4(1, 1, 1, 1);


    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesExtended props = _Properties[unity_InstanceID];
    o.color = props.color;
    o.id    = float(unity_InstanceID);
    o.data  = props.data;
    o.pos  = props.opos;

    ipos    = float3(_Properties[unity_InstanceID].trmat[0][3], 
                    _Properties[unity_InstanceID].trmat[1][3], 
                    _Properties[unity_InstanceID].trmat[2][3]);

    vel     = float3(_Properties[unity_InstanceID].oscmat[0][3], 
                    _Properties[unity_InstanceID].oscmat[1][3], 
                    _Properties[unity_InstanceID].oscmat[2][3]);
    #endif

    float2 baseduv          = frac(TRANSFORM_TEX(v.texcoord, _FurTex));
    float noiseGrey         = noise(float3(baseduv, 1.0) * _UvMultiplier + ipos.xyz * _PosMultiplier + float3(0, 0, _Time.y * _timeMultiplier));
    o.noiseLength           = smoothstep(_NoiseFurBased - _NoiseFurThick * 0.5 - _NoiseFurSmooth, _NoiseFurBased - _NoiseFurThick * 0.5, noiseGrey) * 
                            (1.0 - smoothstep(_NoiseFurBased + _NoiseFurThick * 0.5, _NoiseFurBased + _NoiseFurThick * 0.5 + _NoiseFurSmooth, noiseGrey));
    float furlength         = _FurLength * o.noiseLength;

    //this matrix operation is not correct;
    float3 worldGravity     = mul(unity_WorldToObject, float4(_Gravity.xyz, 1)).xyz; //as the instance are un local space we need tro rotat the gravity vector according to the inverse matrix of the instance
    vel                     = mul(unity_WorldToObject, float4(vel.xyz, 1)).xyz; //as the instance are un local space we need tro rotat the gravity vector according to the inverse matrix of the instance

    fixed3 direction        = lerp(v.normal, worldGravity.xyz * _GravityStrength + v.normal * (1.0 - _GravityStrength), FUR_MULTIPLIER);

    //wind
    float2 uv               = frac(TRANSFORM_TEX(v.texcoord, _GravityTex) + float2(frac(_Time.y * 0.00025), frac(_Time.y * 0.0001)));
    fixed3 noiseDirection   = tex2Dlod(_GravityTex, float4(uv, 0, 0)).xyz * 2.0 - 1.0;
    noiseDirection          *= _GravityTexStrength * (_FurLength * FUR_MULTIPLIER);
    
    vel                     *= -1.0;
    vel                     *= furlength * FUR_MULTIPLIER;
    vel                     *= _VelStrength;
    
    v.vertex.xyz            += normalize(direction + vel + noiseDirection) * furlength * (FUR_MULTIPLIER * 0.5);
}

void surf(Input IN, inout SurfaceOutputStandard o){

    float normtime      = IN.data.y;

    float2 uv   = frac(frac(IN.uv_MainTex * _Tiles) + float2(_Time.y, _Time.y + 512463.156 * IN.data.w) * 0.01);
    fixed4 rgba = tex2D(_MainTex, uv) * IN.color;
    fixed4 fur  = tex2D(_FurTex, frac(IN.uv_MainTex * _TilesFur));
    fixed4 met  = tex2D(_Metallic, frac(IN.uv_MainTex));

    float noiseGrey = noise(float3(IN.uv_MainTex.xy, 1.0) * _UvMultiplier + IN.pos.xyz * _PosMultiplier + float3(0, 0, _Time.y * _timeMultiplier)) * 0.5 + 0.5;
    
    float normy     = saturate(IN.pos.y / _World.y);
    fixed4 ramp     = tex2D(_Ramp, float2(FUR_MULTIPLIER * noiseGrey, normy));

    // float light         = smoothstep(normtime - _LightThick * 0.5 - _LightSmooth, normtime - _LightThick * 0.5, FUR_MULTIPLIER) * 
    //                       (1.0 - smoothstep(normtime + _LightThick * 0.5, normtime + _LightThick * 0.5 + _LightSmooth, FUR_MULTIPLIER));

    o.Albedo        = ramp;
    o.Emission      = texCUBElod (_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission * FUR_MULTIPLIER;
    o.Emission      += o.Albedo * _AlbedoEmission * FUR_MULTIPLIER;
    // o.Emission      += light * o.Albedo;// * smoothstep(0.45, 0.55, 1.0- noiseGrey);
    o.Metallic      = met.r;
    o.Smoothness    = _Glossiness;

    float val           = lerp(_Cutoff, _CutoffEnd, FUR_MULTIPLIER);
    float mask          = smoothstep(val - _SmoothThick * 0.5, val + _SmoothThick * 0.5, fur.a);

    float viewDirBlend  =   1 - (FUR_MULTIPLIER * FUR_MULTIPLIER);
    viewDirBlend        += dot(IN.viewDir, o.Normal) - _EdgeFade;

    float maskBase      = smoothstep(_BaseCutOff - _BaseThickness * 0.5, _BaseCutOff + _BaseThickness * 0.5, FUR_MULTIPLIER);

    o.Alpha     = (mask * viewDirBlend) * maskBase * IN.noiseLength;// * IN.color.a
    clip(o.Alpha > _CutOut ? 1.0 : -1.0);
}