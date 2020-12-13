Shader "BonjourLab/BodyStudy_06"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Ramp ("_Ramp (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Roughness ("Roughness", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        _SmoothEmissive("SmoothEmissive", Range(0, 1)) = 0.0
        _ThickEmissive("ThickEmissive", Range(0, 1)) = 0.1
        _PointEmissive("PointEmissive", Range(0, 1)) = 0.5
        _PointEmissiveMul ("PointEmissiveMul", Range(0,1)) = 0.5

        _AlphaTest("Alpha Test", Range(0,1)) = 1.0
        _MinAlpha("MinAlpha", Range(0, 1)) = 0.0
        _MaxAlpha("MaxAlpha", Range(0, 1)) = 1.0
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
    		float4 screenPos;
            float3 worldRefl;
            INTERNAL_DATA
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Vertex/SimpleVertexExtended.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Roughness;
        samplerCUBE _Cube;
        sampler2D _Ramp;
        
        half _EnviroBlur;
        float _GlobalEmission;
        float _AlbedoEmission;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _AlphaTest;
        float _SmoothEmissive;
        float _ThickEmissive;
        float _PointEmissive;
        float _PointEmissiveMul;
        float _MinAlpha;
        float _MaxAlpha;

         float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float stepper       = 0.25 + step(0.25, IN.data.y) * 0.5;
            float2 uv           = float2(IN.color.r, stepper);
            float noiseOffset   = smoothstep(_MinAlpha, _MaxAlpha, IN.color.r);
            float noiseEmissive = smoothstep(_PointEmissive - _ThickEmissive * 0.5 - _SmoothEmissive, _PointEmissive - _ThickEmissive * 0.5, IN.color.r) * 
                                  (1.0 - smoothstep(_PointEmissive + _ThickEmissive * 0.5, _PointEmissive + _ThickEmissive * 0.5 + _SmoothEmissive, IN.color.r));
            
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 r = tex2D (_Roughness, IN.uv_MainTex) * _Color;
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, IN.uv_MainTex));
            // anormal.y       = 1.0 - anormal.y;
            
            fixed4 ramp = tex2D (_Ramp, uv) * IN.color.r;

            o.Albedo = ramp.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = ramp.x * _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;
            o.Emission      += luma(ramp.rgb) * noiseEmissive * _PointEmissiveMul;//IN.data.w;
           

            float discardValue = noiseOffset;
			float4x4 thresholdMatrix =
			{  1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
			13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
			4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
			16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
			};
			float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
			float2 pos = IN.screenPos.xy / IN.screenPos.w;
			pos *= _ScreenParams.xy; // pixel position

			clip(discardValue - thresholdMatrix[fmod(pos.x, 4)] * _RowAccess[fmod(pos.y, 4)]);

        }
        ENDCG
    }
    FallBack "Diffuse"
}
