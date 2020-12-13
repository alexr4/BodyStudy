Shader "BonjourLab/BodyStudy_12"
{
    Properties
    {
        [Header(Mat Properties)] 
        _Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
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
		_SmoothThick ("_SmoothThick", Range(0,1)) = 0.4

		_GravityTex ("Gravity tex", 2D) = "black" {}
		_Gravity ("Gravity direction", Vector) = (0,0,1,0)
		_GravityTexStrength("GravityTexStrength", float) = 2.0
		_GravityStrength ("G strenght", Range(0,1)) = 0.25

        _VelStrength("VelStrength", Range(0, 1)) = 0.1

    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        // Blend SrcAlpha OneMinusSrcAlpha
        // Blend OneMinusDstColor One // Soft Additive
		ZWrite On
		LOD 200

        CGPROGRAM    
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface frag Standard fullforwardshadows vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.0
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"

        float _BaseAlpha;
	

        void frag (Input IN, inout SurfaceOutputStandard o)
        {
           fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = _BaseAlpha;
        }
        ENDCG

        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.025
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.05
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.075
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.125
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.15
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.175
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.2
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.225
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.25
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.275
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.3
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.325
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.35
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.375
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.4
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.425
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.45
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.475
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.5
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.525
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.55
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.575
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.6
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.625
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.65
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.675
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.7
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.725
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.75
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.775
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.8
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.825
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.85
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.875
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.9
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.925
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.95
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.975
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
        
        CGPROGRAM
        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #pragma surface surf Standard fullforwardshadows alpha:blend vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 4.0
        #define FUR_MULTIPLIER 0.1
        #include "Assets/Scripts/Vertex/FurVertexExtended.hlsl"
        ENDCG
    }
}
