Shader "Custom/FloorReflection"
{
    Properties
    {
        [Header(Main Params)]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.5

        
        [Header(Reflection Params)]
        _ReflectionTex ("Reflection Texture (RGB)", 2D) = "white" {}
        _ReflectionMask ("Reflection Mask", 2D) = "white" {}
        _ReflectionFactor ("Reflection Factor", Range(0,1)) = 1.0
        _RelfectionPower ("Relfection Power", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _ReflectionTex;
        sampler2D _ReflectionMask;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
            float2 uv_ReflectionMask;
        };

        half _Glossiness;
        fixed4 _Color;
        float _ReflectionFactor;
        float _RelfectionPower;
        float _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 screenPos    = IN.screenPos.xy / IN.screenPos.w;
            screenPos.x         = 1.0 - screenPos.x;

            // Albedo comes from a texture tinted by color
            fixed4 refl         = tex2D(_ReflectionTex, screenPos) * _ReflectionFactor;
            fixed4 c            = tex2D (_MainTex, IN.uv_MainTex) * _Color * (1.0 - _ReflectionFactor);
            float reflmask      = tex2D (_ReflectionMask, IN.uv_ReflectionMask).r;
            c                   = saturate(c);
            c                   += (refl * lerp(1, 10, _RelfectionPower)) * reflmask;
            
            o.Albedo = c.rgb;
            o.Metallic = _Metallic * reflmask;
            o.Smoothness = _Glossiness;
            // o.Alpha = c.a;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
