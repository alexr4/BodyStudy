Shader "BonjourLab/BodyStudy_28"
{
    Properties
    {
        [Header(Mat Properties)] 
         _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CutOut ("CutOut", Range(0.0, 1)) = 0.0
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _Metallic ("_Metallic", 2D) = "black" {}
		_MetalInc ("_MetalInc", Range(0.00, 1)) = 0.00
        _Roughness ("Roughness", 2D) = "grey" {}
		_RoughInc ("_RoughInc", Range(0.00, 1)) = 0.00
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5
        _AlbedoRamp ("_AlbedoRamp (RGB)", 2D) = "white" {}

        _AlphaTest("_AlphaTest", float) = 1

        [Header(VAT1 Properties)]
        _boundingMax("Bouding max", Float) = 1.0
        _boundingMin("Bounding min", Float) = 1.0

        _numOfFrames("Number of Frames", Float) = 0
        _speed("Speed", Float) = 0.33

        [MaterialToggle] _pack_normal("Pack normal", Float) = 0
        _posTex("Position texture", 2D) = "white"{}
        _nTex("Normal texture", 2D) = "grey"{}
		_TimeControl ("TimeControl", Range(0.00, 1)) = 0.00
        [MaterialToggle] _isControlldByInstance("Is Controlled by Instance", Float) = 0

        [Header(VAT2 Properties)]
        _boundingMax2("Bouding max", Float) = 1.0
        _boundingMin2("Bounding min", Float) = 1.0
        _posTex2("Position texture", 2D) = "white"{}
        _nTex2("Normal texture", 2D) = "grey"{}
    }
    SubShader
    {
        Tags {"RenderType"="TransparentCutout" "Queue" = "AlphaTest" "LightMode"="ForwardBase"  "IgnoreProjector"="True"}
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        LOD 200

        CGPROGRAM
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv;
            float4 color;
            float id;
    		float4 screenPos;
            float4 data;
            float4 pos;
            float3 worldRefl;
            INTERNAL_DATA
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Utils/noises.hlsl"
        #include "Assets/Scripts/Utils/easing.hlsl"
        #include "Assets/Scripts/Vertex/VertexAnimationTexturePhysics.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Metallic;
        sampler2D _Roughness;
        samplerCUBE _Cube;
        sampler2D _AlbedoRamp;

        half _EnviroBlur;
        fixed4 _Color;
        float _GlobalEmission;
        float _AlbedoEmission;
        float _AlphaTest;
        float _MetalInc;
        float _RoughInc;

          
        float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv       = (IN.pos.x >= 0) ? IN.uv_MainTex.xy : float2(1.0 - IN.uv_MainTex.x, IN.uv_MainTex.y);

            float divider    = 7.0;
            float offset    = 1.0 / divider;
            uv              = float2(uv.x / divider, uv.y);
            uv.x            += floor(IN.pos.w * divider) * offset;

            fixed4 argb     = tex2D (_MainTex, uv);
            fixed4 arough   = tex2D (_Roughness, uv);
            fixed4 ametal   = tex2D (_Metallic, uv);
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, uv));

            float rnd       = step(0.5, random(IN.pos.w)) * 0.5 + 0.25;
            fixed4 ramp     = tex2D(_AlbedoRamp, float2(IN.pos.w, rnd));


            // Metallic and smoothness come from slider variables
            o.Albedo        = argb * IN.color.rgb + ramp * .25 + anormal * 0.15;
            o.Normal        = anormal;
            o.Metallic      = ametal.r * _MetalInc;
            o.Smoothness    = arough.r * _RoughInc;
            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;
            o.Alpha         = argb.a;

            float discardValue = smoothstep(0, _AlphaTest, IN.color.a);
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
