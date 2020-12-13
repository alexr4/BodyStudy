Shader "BonjourLab/BodyStudy_16"
{
    Properties
    {
        [Header(Main Properties)] 
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_BumpMap ("BumpMap (RGB) Trans (A)", 2D) = "white" {}
		_Tiles ("Tiles", Vector) = (1, 1, 0, 0)
		_Metallic ("Metallic", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
        _BaseAlpha("BaseAlpha", Range(0, 1)) = 0.0
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission("Global Emission", Range(0, 1)) = 0.1
        _EnviroBlur("Environment Blur", Range(0, 1)) = 0.1
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        [Header(Alpha Discard Fur Properties)] 
        _CutOut("_CutOut", Range(0, 1)) = 0.01

        [Header(BasedFur Properties)] 
		_FurTex ("Fur Tex (RGB) Trans (A)", 2D) = "white" {}
		_Ramp ("Ramp", 2D) = "white" {}
		_TilesFur ("_TilesFur", Vector) = (1, 1, 0, 0)
        _FurLength ("Fur Length", Range (.0002, 1)) = .25
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5 // how "thick"
		_CutoffEnd ("Alpha cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		_EdgeFade ("Edge Fade", Range(0,1)) = 0.4
		_SmoothThick ("Smooth Thick", Range(0,1)) = 0.4
        _BaseCutOff("Base CutOff", Range(0, 1)) = 0.5
        _BaseThickness("Base Thickness", Range(0, 1)) = 1

        [Header(Noise Fur Length)]
        _NoiseFurBased("Noise Based Pos", Range(0, 1)) = 0.5
        _NoiseFurThick("Noise Thick", Range(0, 1)) = 0.1
        _NoiseFurSmooth("Noise Smooth", Range(0, 1)) = 0.05

        [Header(Behaviors Fur Properties)] 
		_GravityTex ("Gravity tex", 2D) = "black" {}
		_GravityTexStrength("GravityTexStrength", float) = 2.0
		_Gravity ("Gravity direction", Vector) = (0,0,1,0)
		_GravityStrength ("G strenght", Range(0,1)) = 0.25
        _VelStrength("VelStrength", Range(0, 1)) = 0.1

        [Header(Light Behaviors Fur Properties)]
        _LightThick("Light thickness", Range(0, 1)) = 0.01
        _LightSmooth("Light smothness", Range(0, 1)) = 0.01
        
        [Header(Fur Textures Properties)] 
        _UvMultiplier("_UvMultiplier", Float) = 1
        _PosMultiplier("_PosMultiplier", Float) = 1
        _timeMultiplier("_timeMultiplier", Float) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 200

        CGPROGRAM 
        // Physically based Standard lighting model, and enable shadows on all light types
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface frag Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.0
        #include "Assets/Scripts/Vertex/FurVertexExtended-5Based.hlsl"

         sampler2D _BumpMap;
        float _BaseAlpha;

        void frag (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 argb     = tex2D (_MainTex, frac(IN.uv_MainTex));
            fixed4 ametal   = tex2D (_Metallic, frac(IN.uv_MainTex));
            float3 anormal  = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap));

            // Metallic and smoothness come from slider variables
            o.Albedo        = argb * IN.color.rgb;
            o.Normal        = anormal;
            o.Metallic      = ametal.r;
            o.Smoothness    = _Glossiness;
            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;
            
            o.Alpha         = _BaseAlpha;
            clip(o.Alpha > 0 ? 1.0 : -1.0);
        }
        ENDCG

        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.025
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.05
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.075
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.125
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.15
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.175
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.2
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.225
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.25
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.275
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.4
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.325
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.35
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.375
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.4
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.425
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.45
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.475
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.5
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.525
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.55
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.575
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.6
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.625
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.65
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.675
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.7
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.725
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.75
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.775
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.8
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.825
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.85
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.875
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.9
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.925
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.95
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.975
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended-5.hlsl"
        ENDCG
    }
}
