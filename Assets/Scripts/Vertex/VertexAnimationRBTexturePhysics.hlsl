uniform sampler2D _posTex;
uniform sampler2D _rotTex;

uniform float _boundingMax;
uniform float _boundingMin;
uniform float _boundingMax1;
uniform float _boundingMin1;
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
    o.pos       = v.vertex.xyzw;
    o.norm      = float4(v.normal.xyz, 1);
    float seq   = 1;

    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
    MeshPropertiesPhysisc props = _Properties[unity_InstanceID];
    o.id    = float(unity_InstanceID);
    o.color = props.color;
    o.data  = props.data;
    o.pos  = float4(v.vertex.xyz, props.opos.w); 
    o.opos      = props.opos; 

    id          = o.data.x;
    ti          = props.vel.w;
    o.data.y    = (props.acc.w == 0) ? props.data.y : 1.0 - ti;
    #endif

    float time         = (_isControlldByInstance) ? ti : _TimeControl;
    float timeInFrames = (ceil(frac(time) * _numOfFrames) / _numOfFrames);// + (1.0 / _numOfFrames);

    float3 texPos = tex2Dlod(_posTex, float4(v.texcoord1.x, (1 - timeInFrames) + v.texcoord1.y, 0, 0));
	float4 texRot = tex2Dlod(_rotTex, float4(v.texcoord1.x, (1 - timeInFrames) + v.texcoord1.y, 0, 0));

    float expand1 = _boundingMax1 - _boundingMin1;
    texPos.xyz *= expand1;
    texPos.xyz += _boundingMin1;
    texPos.x *= -1;  //flipped to account for right-handedness of unity
    texPos = texPos.xzy;  //swizzle y and z because textures are exported with z-up

    //expand normalised pivot vertex colour values to world space
    float expand = _boundingMax - _boundingMin;
    float3 pivot = v.color.rgb;
    pivot.xyz *= expand;
    pivot.xyz += _boundingMin;
    pivot.x *=  -1;
    pivot = pivot.xzy;
    float3 atOrigin = v.vertex.xyz - pivot;

    //calculate rotation
    texRot = texRot.gbra;
    texRot *= 2.0;
    texRot -= 1.0;
    // textureRot = floor(textureRot * 1000)/1000;
    float4 quat = 0;

    //swizzle and flip quaternion from ue4 to unity
    quat.xyz = -texRot.xzy;
    quat.w = texRot.w;
    quat.yz = -quat.yz;
    quat.x = -texRot.x;
    quat.y = texRot.z;
    quat.z = texRot.y;
    quat.w = texRot.w;
    quat = float4(0,0,0,1);
    quat = texRot;

    float3 rotated = atOrigin + 2.0 * cross(quat.xyz, cross(quat.xyz, atOrigin) + quat.w * atOrigin);

    v.vertex.xyz = rotated;
    v.vertex.xyz += pivot;
    v.vertex.xyz += texPos;

    //calculate normal
    float3 rotatedNormal = v.normal + 2.0 * cross(quat.xyz, cross(quat.xyz, v.normal) + quat.w * v.normal);
    v.normal = rotatedNormal;

}