Shader "BonjourLab/BodyStudy_13"
{
    Properties
    {
        [Header(Mat Properties)] 
        _Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Ramp ("Base (RGB) _Ramp", 2D) = "white" {}
		_Tiles ("Tiles", Vector) = (1, 1, 0, 0)
		_TilesFur ("_TilesFur", Vector) = (1, 1, 0, 0)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _BaseAlpha("BaseAlpha", Range(0, 1)) = 0.0
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        [Header(Fur Properties)] 
        _FurLength ("Fur Length", Range (.0002, 1)) = .25
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5 // how "thick"
		_CutoffEnd ("Alpha cutoff end", Range(0,1)) = 0.5 // how thick they are at the end
		_EdgeFade ("Edge Fade", Range(0,1)) = 0.4
		_SmoothThick ("Smooth Thick", Range(0,1)) = 0.4
        _BaseCutOff("Base CutOff", Range(0, 1)) = 0.5
        _BaseThickness("Base Thickness", Range(0, 1)) = 1

		_GravityTex ("Gravity tex", 2D) = "black" {}
		_Gravity ("Gravity direction", Vector) = (0,0,1,0)
		_GravityTexStrength("GravityTexStrength", float) = 2.0
		_GravityStrength ("G strenght", Range(0,1)) = 0.25

        _VelStrength("VelStrength", Range(0, 1)) = 0.1

        _CutOut("_CutOut", Range(0, 1)) = 0.01

        
        _UvMultiplier("_UvMultiplier", Float) = 1
        _PosMultiplier("_PosMultiplier", Float) = 1
        _timeMultiplier("_timeMultiplier", Float) = 1
        _GlobalEmission("Global Emission", Range(0, 1)) = 0.1

    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue" = "AlphaTest"  "LightMode"="ForwardBase" "IgnoreProjector"="True"}
		ZWrite On
		LOD 200

        CGPROGRAM 
        // Physically based Standard lighting model, and enable shadows on all light types
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface frag NoLighting Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.0
        #include "Assets/Scripts/Vertex/FurVertexExtended-2Based.hlsl"

        float _BaseAlpha;
	

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo; 
            c.a = s.Alpha;
            return c;
        }
	

        void frag (Input IN, inout SurfaceOutput o)
        {
            fixed4 rgba = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            o.Albedo    = rgba;
            o.Alpha     = _BaseAlpha;
        }
        ENDCG

        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.025
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.05
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.075
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.125
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.15
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.175
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.2
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.225
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.25
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.275
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.3
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.325
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.35
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.375
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.4
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.425
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.45
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.475
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.5
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.525
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.55
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.575
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.6
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.625
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.65
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.675
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.7
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.725
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.75
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.775
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.8
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.825
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.85
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.875
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.9
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.925
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.95
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.975
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alphatest:_CutOut vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended-2.hlsl"
        ENDCG
    }
}
