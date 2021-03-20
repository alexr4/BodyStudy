Shader "BonjourLab/BodyStudy_33"
{
    Properties
    {
        [Header(Mat Properties)] 
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 2)) = 1
        _AO ("AO", 2D) = "white" {}
        _Glossiness ("_Glossiness", Range(0,1)) = 0.5
        _Metallic ("_Metallic", 2D) = "black" {}
        _Roughness ("Roughness", 2D) = "grey" {}
        
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        _AlphaTest("_AlphaTest", float) = 1

        [Header(SubSurface Scattering param)]
        _Distortion("Distortion", Float) = 1.0
        _Power("Power", Float) = 1.0
        _Scale("Scale", Float) = 1.0
        _LocalThickness("LocalThickness", 2D) = "grey" {}
        _Attenuation("Attenuation", Float) = 1.0
        _Ambient("Ambient", Color) = (1, 1, 1, 1)

        
        [Header(Triplanar texture projection)]
        [MaterialToggle] _UseTriplanar("Use Triplanar Texture Projection", Float) = 0 
        _TriplanarTexture("Triplanar Texture", 2D) = "black" {}
        _TriplanarRough("Triplanar Rough Texture", 2D) = "black" {}
        _MapScale("Map Scale", Float) = 1
        _BlendOffset ("Blend Offset", Range(0, 0.5)) = 0.25
		_BlendExponent ("Blend Exponent", Range(1, 8)) = 2
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"  "LightMode"="ForwardBase"}
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
            float3 vertex;
            float3 normal;
            INTERNAL_DATA
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Utils/noises.hlsl"
        #include "Assets/Scripts/Utils/easing.hlsl"
        #include "Assets/Scripts/Vertex/SimpleVertexExtendedTriplanar.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardTranslucent fullforwardshadows addshadow vertex:vertex
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

        float _NormalScale;

        half _Glossiness;
        fixed4 _Color;
        float _AlphaTest;

        float thickness;
        float _Distortion;
        float _Power;
        float _Scale;
        sampler2D _LocalThickness;
        float _Attenuation;
        fixed4 _Ambient;

        sampler2D _TriplanarTexture;
        sampler2D _TriplanarRough;
        float _MapScale;
        float _BlendExponent;
        float _BlendOffset;

        struct TriplanarData{
            float2 tx;
            float2 ty;
            float2 tz;
            float3 bf;
        };

         float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        #include "UnityPBSLighting.cginc"
        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            // Original colour
            fixed4 pbr = LightingStandard(s, viewDir, gi);

            //Fast SSS pased on Alan Zucconi Tutorial : https://www.alanzucconi.com/2017/08/30/fast-subsurface-scattering-1/
            float3 L    = gi.light.dir;
            float3 V    = viewDir;
            float3 N    = s.Normal;
            float H     = normalize(L + N * _Distortion);

            float VdotH = pow(saturate(dot(V, -H)), _Power) * _Scale;
            float3 I    = _Attenuation * (VdotH + _Ambient.rgb) * thickness;

            pbr.rgb     = pbr.rgb + gi.light.color * I;

            return pbr;
        }

        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi); 
        }

        TriplanarData Triplanar(Input IN){
            // float3 noised   = noise(IN.opos.xyz * _OposScale + IN.pos.xyz * _PosScale + IN.opos.w * _RndScale + IN.data.w * _RndScale2);
            // noised          *= _TriplanarNoiseScale;
            // noised          = noised * 2.0 - 1.0;

            // Blending factor of triplanar mapping
            float3 bf = normalize(abs(IN.normal.xyz));
            bf = saturate(bf - _BlendOffset);
	        bf = pow(bf, _BlendExponent);
            bf /= dot(bf, (float3) 1.0);

            // Triplanar mapping
            float2 tx = IN.vertex.yz * _MapScale;
            float2 ty = IN.vertex.zx * _MapScale;
            float2 tz = IN.vertex.xy * _MapScale;

            TriplanarData mapping;
            mapping.tx = tx;
            mapping.ty = ty;
            mapping.tz = tz;
            mapping.bf = bf;

            return mapping;
        }

        fixed4 GetTextureFromTriplanar(sampler2D tex, TriplanarData tp){
            fixed4 cx = tex2D(tex, tp.tx) * tp.bf.x;
            fixed4 cy = tex2D(tex, tp.ty) * tp.bf.y;
            fixed4 cz = tex2D(tex, tp.tz) * tp.bf.z;

            return (cx + cy + cz);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
             // Albedo comes from a texture tinted by color
            fixed4 argb         = tex2D (_MainTex, frac(IN.uv_MainTex));
            fixed4 aao          = tex2D (_AO, frac(IN.uv_MainTex));
            fixed4 arough       = tex2D (_Roughness, frac(IN.uv_MainTex));
            fixed4 ametal       = tex2D (_Metallic, frac(IN.uv_MainTex));
            float3 anormal      = UnpackScaleNormal(tex2D (_BumpMap, IN.uv_BumpMap), _NormalScale);

            TriplanarData tpd   = Triplanar(IN);
            fixed4 pattern      = GetTextureFromTriplanar(_TriplanarTexture, tpd);
            fixed4 patternRough = GetTextureFromTriplanar(_TriplanarRough, tpd);

            thickness           = tex2D(_LocalThickness, IN.uv_MainTex) * (1.0 - patternRough);

            o.Albedo        = pattern * IN.color * _Color * aao.r;
            o.Normal        = anormal;
            o.Metallic      = ametal.r;
            o.Smoothness    = patternRough.r * _Glossiness;// max(arough.r, patternRough.r) * _Glossiness;
            // // o.Alpha         = argb.a;

            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      *= lerp(luma(o.Albedo), o.Albedo, _AlbedoEmission);

            // float discardValue = IN.data.y;//smoothstep(0, IN.data.y, _AlphaTest);
			// float4x4 thresholdMatrix =
			// {  1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
			// 13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
			// 4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
			// 16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
			// };
			// float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
			// float2 pos = IN.screenPos.xy / IN.screenPos.w;
			// pos *= _ScreenParams.xy; // pixel position

			// clip(discardValue - thresholdMatrix[fmod(pos.x, 4)] * _RowAccess[fmod(pos.y, 4)]);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
