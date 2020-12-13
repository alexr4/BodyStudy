uniform sampler2D _posTex;
uniform sampler2D _nTex;
uniform sampler2D _posTex2;
uniform sampler2D _nTex2;
uniform float _boundingMax;
uniform float _boundingMin;
uniform float _boundingMax2;
uniform float _boundingMin2;
uniform float _numOfFrames;
uniform float _speed;
uniform float _pack_normal;
uniform float _TimeControl;
uniform float _isControlldByInstance;

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
StructuredBuffer<MeshPropertiesPhysisc> _Properties;
#endif

/** When redefining the unity_ObjectToWorld Matrix, its inverse is not redefine, which produce an error in the lighting
https://forum.unity.com/threads/trying-to-rotate-instances-with-drawmeshinstancedindirect-shader-but-the-normals-get-messed-up.707600/
*/
float4x4 inverse(float4x4 input)
{
    #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
    float4x4 cofactors = float4x4(
        minor(_22_23_24, _32_33_34, _42_43_44),
        -minor(_21_23_24, _31_33_34, _41_43_44),
        minor(_21_22_24, _31_32_34, _41_42_44),
        -minor(_21_22_23, _31_32_33, _41_42_43),
        -minor(_12_13_14, _32_33_34, _42_43_44),
        minor(_11_13_14, _31_33_34, _41_43_44),
        -minor(_11_12_14, _31_32_34, _41_42_44),
        minor(_11_12_13, _31_32_33, _41_42_43),
        minor(_12_13_14, _22_23_24, _42_43_44),
        -minor(_11_13_14, _21_23_24, _41_43_44),
        minor(_11_12_14, _21_22_24, _41_42_44),
        -minor(_11_12_13, _21_22_23, _41_42_43),
        -minor(_12_13_14, _22_23_24, _32_33_34),
        minor(_11_13_14, _21_23_24, _31_33_34),
        -minor(_11_12_14, _21_22_24, _31_32_34),
        minor(_11_12_13, _21_22_23, _31_32_33)
        );
    #undef minor
    return transpose(cofactors) / determinant(input);
}

void setup(){
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesPhysisc props = _Properties[unity_InstanceID];
    unity_ObjectToWorld = mul(props.trmat, mul(props.rotmat, props.scmat));
    unity_WorldToObject = inverse(unity_ObjectToWorld);
    #endif
}


void vertex(inout appdata_full v, out Input o){
    UNITY_INITIALIZE_OUTPUT(Input, o);

    float ti    = 0;
    float id    = 0;
    o.color     = float4(1.0, 1.0, 1.0, 1.0);
    o.pos      = v.vertex.xyzw;
    float seq   = 1;

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesPhysisc props = _Properties[unity_InstanceID];
    o.id    = float(unity_InstanceID);
    o.color = props.color;
    o.data  = props.data;
    o.pos  = float4(v.vertex.xyz, props.opos.w); 

    id      = o.data.x;
    ti      = o.data.y;
    seq     = o.data.w;
    #endif

    float speed       = (seq == 0) ? lerp(0.6, 0.6 * 2, o.pos.w) : _speed;

    float time        = (_isControlldByInstance) ? ti * speed : _TimeControl;
    float timeInFrame = (ceil(frac(-time) * _numOfFrames) / _numOfFrames) + (1.0 / _numOfFrames);

    float4 texPos     = float4(0, 0, 0, 0);
    float4 texNorm    = float4(0, 0, 0, 0);
    float expand      = 0;

    if(seq == 0){
        texPos     = tex2Dlod(_posTex, float4(v.texcoord1.x, timeInFrame + v.texcoord1.y, 0, 0));
        texNorm    = tex2Dlod(_nTex, float4(v.texcoord1.x, timeInFrame + v.texcoord1.y, 0, 0));
        expand     = _boundingMax - _boundingMin;
    }else{
        texPos     = tex2Dlod(_posTex2, float4(v.texcoord1.x, timeInFrame + v.texcoord1.y, 0, 0));
        texNorm    = tex2Dlod(_nTex2, float4(v.texcoord1.x, timeInFrame + v.texcoord1.y, 0, 0));
        expand     = _boundingMax2 - _boundingMin2;
    }

    //is space gamma so use that
    // texPos.xyz        = pow(texPos.xyz, 2.2);
    
    //compute the new position
    //expand normalized pos value to the world space

    texPos.xyz      *= expand;
    texPos.xyz      += _boundingMin;
    texPos.x        *= -1.0; //we flip x axis
    v.vertex.xyz    += texPos.xzy; 

    //compute the normal
    if(_pack_normal){
        float alpha = texPos.w * 1024;
        float2 f2;
        f2.x        = floor(alpha / 32.0) / 31.5;
        f2.y        = (alpha - (floor(alpha / 32.0) * 32.0)) / 31.5;

        //decode float2 ad float3
        float3 f3;
        f2          *= 4;
        f2          -= 2;
        float f2dot = dot(f2, f2);
        f3.xy       = sqrt(1 - (f2dot/4.0)) * f2;
        f3.z        = 1 - (f2dot/2.0);
        f3          = clamp(f3, -1.0, 1.0);

        v.normal    = f3;
    }else{
        texNorm     = texNorm * 2.0 - 1.0;
        v.normal    = texNorm.xyz;
    }
}