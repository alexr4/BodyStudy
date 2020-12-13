struct MeshProperties {
    float4x4 trmat;
    float4x4 rotmat;
    float4x4 scmat;
    float4x4 oscmat;
    float4 data;
    float4 color;
};

struct MeshPropertiesExtended {
    float4x4 trmat;
    float4x4 rotmat;
    float4x4 scmat;
    float4x4 oscmat;
    float4 opos;
    float4 data;
    float4 color;
};

struct MeshPropertiesPhysisc {
    float4x4 trmat;
    float4x4 rotmat;
    float4x4 scmat;
    float4x4 oscmat;
    float4 opos;
    float4 vel;
    float4 acc;
    float4 data;
    float4 color;
};