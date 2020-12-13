Shader "BonjourLab/BodyStudy_10"
{
    Properties
    {
        [Header(Mat Properties)] 
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CutOut ("CutOut", Range(0.0, 1)) = 0.0
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _AO ("AO", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", 2D) = "black" {}
        _Roughness ("Roughness", 2D) = "black" {}
        _AlphaTest("Alpha Test", Range(0, 1)) = 1
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

         [Header(VAT Properties)]
        _boundingMax("Bouding max", Float) = 1.0
        _boundingMin("Bounding min", Float) = 1.0
        _numOfFrames("Number of Frames", Float) = 0
        _speed("Speed", Float) = 0.33

        [MaterialToggle] _pack_normal("Pack normal", Float) = 0
        _posTex("Position texture", 2D) = "white"{}
        _nTex("Normal texture", 2D) = "grey"{}
		_TimeControl ("TimeControl", Range(0.00, 1)) = 0.00
        [MaterialToggle] _isControlldByInstance("Is Controlled by Instance", Float) = 0

        [Header(Wind animation)]
		_Wind ("Wind (RGB)", 2D) = "white" {}
        _WindFrequency("WindFrequency", Vector) =(0.01, 0.01, 0.01, 0)
        _WindPower("WindPower", float) = 0.025
    }
    SubShader
    {
        
        Tags { "RenderType"="TransparentCutout" "Queue" = "AlphaTest"  "LightMode"="ForwardBase" "IgnoreProjector"="True"}
		Blend SrcAlpha OneMinusSrcAlpha
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
        #include "Assets/Scripts/Utils/noises.hlsl"
        #include "Assets/Scripts/Utils/easing.hlsl"
        #include "Assets/Scripts/Utils/MatrixFormAngleAxis.hlsl"
        #include "Assets/Scripts/Vertex/VertexAnimationTextureExtended.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _AO;
        sampler2D _Metallic;
        sampler2D _Roughness;
        samplerCUBE _Cube;
        
        half _EnviroBlur;
        float _GlobalEmission;
        float _AlbedoEmission;

        half _Glossiness;
        fixed4 _Color;
        float _AlphaTest;

         float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
             // Albedo comes from a texture tinted by color
            fixed4 argb     = tex2D (_MainTex, frac(IN.uv_MainTex));
            fixed4 aao      = tex2D (_AO, frac(IN.uv_MainTex));
            fixed4 arough   = tex2D (_Roughness, frac(IN.uv_MainTex));
            fixed4 ametal   = tex2D (_Metallic, frac(IN.uv_MainTex));
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));

            // Metallic and smoothness come from slider variables
            o.Albedo        = argb * IN.color.rgb * aao.rgb;
            o.Normal        = anormal;
            o.Metallic      = ametal.r;
            o.Smoothness    = arough.r * _Glossiness;
            o.Alpha         = argb.a;

            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;

            // Screen-door transparency: Discard pixel if below threshold.
			// based on https://ocias.com/blog/unity-stipple-transparency-shader/
            float alphaTest     = (_isControlldByInstance) ? IN.data.y : _TimeControl;
			float discardValue  = smoothstep(0, _AlphaTest, alphaTest);
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
