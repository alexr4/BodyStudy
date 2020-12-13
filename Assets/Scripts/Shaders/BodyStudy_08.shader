Shader "BonjourLab/BodyStudy_08"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _AO ("AO", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", 2D) = "black" {}
        _Roughness ("Roughness", 2D) = "grey" {}
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        [Header(Noise Emission lines)] 
        _Ramp ("_Ramp (RGB)", 2D) = "white" {}
        _NoiseComplexity("NoiseComplexity", float) = 0.75 
        _SmoothEmissive("SmoothEmissive", Range(0, 1)) = 0.0
        _ThickEmissive("ThickEmissive", Range(0, 1)) = 0.1
        _PointEmissive("PointEmissive", Range(0, 1)) = 0.5
        _PointEmissiveMul ("PointEmissiveMul", Range(0,1)) = 0.5

        [Header(Y edges on Noise Emission lines)] 
        _SmoothYEmissive("SmoothYEmissive", Range(0, 1)) = 0.0
        _ThickYEmissive("ThickYEmissive", Range(0, 1)) = 0.1
        _PointYSpeedMul ("_PointYSpeedMul", Range(0,1)) = 0.25
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 200
        Cull Off

        CGPROGRAM
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
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Vertex/SimpleVertexExtended.hlsl"
        #include "Assets/Scripts/Utils/noises.hlsl"
        #include "Assets/Scripts/Utils/easing.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Roughness;
        sampler2D _AO;
        sampler2D _Metallic;
        samplerCUBE _Cube;
        sampler2D _Ramp;
        
        half _EnviroBlur;
        float _GlobalEmission;
        float _AlbedoEmission;

        half _Glossiness;
        fixed4 _Color;

        float _NoiseComplexity;
        float _SmoothEmissive;
        float _ThickEmissive;
        float _PointEmissive;
        float _PointEmissiveMul;
        float _SmoothYEmissive;
        float _ThickYEmissive;
        float _PointYSpeedMul;

         float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 argb     = tex2D (_MainTex, frac(IN.uv_MainTex));
            fixed4 aao      = tex2D (_AO, frac(IN.uv_MainTex));
            fixed4 arough   = tex2D (_Roughness, frac(IN.uv_MainTex));
            fixed4 ametal   = tex2D (_Metallic, frac(IN.uv_MainTex));
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));
            // anormal.y       = 1.0 - anormal.y;
            
            float noise     = snoise(IN.uv_MainTex * 2.5 + IN.data.y * 0.1) * 0.5 + 0.5;
            noise           = inoutCubic(noise);

            float normy         = IN.pos.y / 2.0;
            float edgeYPoint    = frac(IN.data.z * _PointYSpeedMul);
            edgeYPoint          = inoutQuad(edgeYPoint);
            edgeYPoint          = lerp((_ThickYEmissive + _SmoothYEmissive) * -1.0, 1. + (_ThickYEmissive + _SmoothYEmissive), edgeYPoint);
            float ymask         = smoothstep(edgeYPoint - _ThickYEmissive * 0.5 - _SmoothYEmissive, edgeYPoint - _ThickYEmissive * 0.5, normy) * 
                                 (1.0 - smoothstep(edgeYPoint + _ThickYEmissive * 0.5, edgeYPoint + _ThickYEmissive * 0.5 + _SmoothYEmissive, normy));
            
            float enoise        = snoise(IN.uv_MainTex * _NoiseComplexity + IN.data.y * 0.5) * 0.5 + 0.5;
            float noiseEmissive = smoothstep(_PointEmissive - _ThickEmissive * 0.5 - _SmoothEmissive, _PointEmissive - _ThickEmissive * 0.5, enoise) * 
                                 (1.0 - smoothstep(_PointEmissive + _ThickEmissive * 0.5, _PointEmissive + _ThickEmissive * 0.5 + _SmoothEmissive, enoise));

            
            fixed4 ramp = tex2D (_Ramp, float2(0.5, normy));
            
            o.Albedo        = argb * IN.color.rgb * aao.rgb;
            o.Normal        = anormal;
            o.Metallic      = ametal.r;
            o.Smoothness    = arough.r * _Glossiness;
            // o.Alpha = c.a;

            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;
            o.Emission      += noiseEmissive * _PointEmissiveMul * ymask * ramp.rgb;;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
