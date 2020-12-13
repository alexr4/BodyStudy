Shader "BonjourLab/BodyStudy_01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        _Roughness ("Roughness", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 200

        CGPROGRAM
        struct Input
        {
            float2  uv_MainTex;
            float4  color;
            float4  data;
            float   id;
            float4  pos;
            float3 worldRefl;
            INTERNAL_DATA
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Vertex/SimpleVertex.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Roughness;
        samplerCUBE _Cube;
        
        half _EnviroBlur;
        float _GlobalEmission;
        float _AlbedoEmission;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 r = tex2D (_Roughness, IN.uv_MainTex) * _Color;
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, IN.uv_MainTex));
            // anormal.y       = 1.0 - anormal.y;

            o.Albedo = c.rgb * IN.color.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = r.x;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
