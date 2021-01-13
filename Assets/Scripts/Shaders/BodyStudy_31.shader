Shader "BonjourLab/BodyStudy_31"
{
    Properties
    {
        [Header(Properties)] 
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _AO ("AO", 2D) = "white" {}
        _Metallic ("_Metallic", Range(0, 1)) = 0
        _Roughness ("Roughness", 2D) = "grey" {}
        _Cube ("Cubemap", CUBE) = "" {}
        _GlobalEmission ("GlobalEmission", Range(0,1)) = 0.5
        _EnviroBlur ("EnviroBlur", Range(0,1)) = 0.5
        _AlbedoEmission ("AlbedoEmission", Range(0,1)) = 0.5

        _AlphaTest("_AlphaTest", float) = 1
        _TriplanarNoiseScale ("Noise Scale", Range(0,2)) = 0.25
        
        _PosScale("Noise pos Scale", Range(0,5))    = 1.0
        _OposScale("Noise opos Scale", Range(0,5))  = 1.0
        _RndScale("Noise rnd Scale", Range(0,5))    = 1.0
        _RndScale2("Noise rnd Scale2", Range(0,5))  = 1.0
        _MapScale("Map Scale", Float) = 1.0

        [Header(VAT Properties)]
        _boundingMax("Bounding Max", Float) = 1.0
		_boundingMin("Bounding Min", Float) = 1.0
		_boundingMax1("Bounding Max1", Float) = 1.0
		_boundingMin1("Bounding Min1", Float) = 1.0
		_numOfFrames("Number Of Frames", int) = 240
		_speed("Speed", Float) = 0.24
		_posTex ("Position Map (RGB)", 2D) = "white" {}
		_rotTex ("Rotation Map (RGB)", 2D) = "grey" {}
		_TimeControl ("TimeControl", Range(0.00, 1)) = 0.00
        [MaterialToggle] _isControlldByInstance("Is Controlled by Instance", Float) = 0
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"  "LightMode"="ForwardBase"}
        LOD 200
        Cull Off

        CGPROGRAM
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float4 color;
            float id;
            float4 opos;
    		float4 screenPos;
            float4 data;
            float4 pos;
            float4 norm;
            float3 worldRefl;
            INTERNAL_DATA
		};

        #include "Assets/Scripts/ComputeShaders/DataStructs.hlsl"
        #include "Assets/Scripts/Vertex/VertexAnimationRBTexturePhysics.hlsl"
        #include "Assets/Scripts/Utils/noises.hlsl"
        #include "Assets/Scripts/Utils/easing.hlsl"
        #include "Assets/Scripts/Utils/MatrixFormAngleAxis.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow vertex:vertex
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:setup 
        #pragma target 5.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _AO;
        float _Metallic;
        sampler2D _Roughness;
        sampler2D _Ramp;
        samplerCUBE _Cube;

        half _EnviroBlur;
        fixed4 _Color;
        float _GlobalEmission;
        float _AlbedoEmission;
        float _AlphaTest;
        float _TriplanarNoiseScale;

        float _PosScale;
        float _OposScale;
        float _RndScale;
        float _RndScale2;
        float _MapScale;

          
        float luma(float3 color) {
            return dot(color, float3(0.299, 0.587, 0.114));
        }

        const float PI = 3.141592653589793238462;

        //https://github.com/keijiro/StandardTriplanar/blob/master/Assets/Triplanar/Shaders/StandardTriplanar.shader
        half4 triplanarMap(Input IN, sampler2D samp)
        {
            float3 noised   = noise(IN.opos.xyz * _OposScale + IN.pos.xyz * _PosScale + IN.opos.w * _RndScale + IN.data.w * _RndScale2);
            noised          *= _TriplanarNoiseScale;
            noised          = noised * 2.0 - 1.0;

            // Blending factor of triplanar mapping
            float3 bf = normalize(abs(IN.norm.xyz + noised));
            bf /= dot(bf, (float3)1);

            // Triplanar mapping
            float2 tx = IN.opos.yz + IN.pos.yz * _MapScale;
            float2 ty = IN.opos.zx + IN.pos.zx * _MapScale;
            float2 tz = IN.opos.xy + IN.pos.xy * _MapScale;

            // Base color
            half4 cx = tex2D(samp, frac(tx * noised)) * bf.x;
            half4 cy = tex2D(samp, frac(ty * noised)) * bf.y;
            half4 cz = tex2D(samp, frac(tz * noised)) * bf.z;
            half4 color = (cx + cy + cz);

            return color;
        }

        float2 TriplanarUV(Input IN){
            float3 noised   = noise(IN.opos.xyz * _OposScale + IN.pos.xyz * _PosScale + IN.opos.w * _RndScale + IN.data.w * _RndScale2);
            noised          *= _TriplanarNoiseScale;
            noised          = noised * 2.0 - 1.0;

            // Blending factor of triplanar mapping
            float3 bf = normalize(abs(IN.norm.xyz + noised));
            bf /= dot(bf, (float3)1);

            // Triplanar mapping
            float2 tx = IN.opos.yz + IN.pos.yz * _MapScale;
            float2 ty = IN.opos.zx + IN.pos.zx * _MapScale;
            float2 tz = IN.opos.xy + IN.pos.xy * _MapScale;

            // Base color
            float2 cx = frac(tx * noised) * bf.x;
            float2 cy = frac(ty * noised) * bf.y;
            float2 cz = frac(tz * noised) * bf.z;

            return (cx + cy + cz);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv       = TriplanarUV(IN); //UV from voronoi fracture is broken (does not match with the UV of the sphere) so we used a triplanar projection to have a noised UV from each instance
            fixed4 argb     = tex2D(_MainTex, uv);
            fixed4 aao      = tex2D(_AO, uv);
            fixed4 arough   = tex2D(_Roughness, uv);
            float3 anormal  = UnpackNormal(tex2D(_BumpMap, uv));

            // Metallic and smoothness come from slider variables
            o.Albedo        = argb * IN.color.rgb * aao.rgb;
            o.Normal        = anormal;
            o.Metallic      = _Metallic;
            o.Smoothness    = arough.r;// * _Glossiness;
            o.Emission      = texCUBElod(_Cube, float4(WorldReflectionVector(IN, o.Normal), lerp(0, 10, _EnviroBlur))).rgb * _GlobalEmission;
            o.Emission      += o.Albedo * _AlbedoEmission;
            // o.Alpha         = argb.a;

            
			float discardValue = smoothstep(_AlphaTest, 1.0, IN.data.y);
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
