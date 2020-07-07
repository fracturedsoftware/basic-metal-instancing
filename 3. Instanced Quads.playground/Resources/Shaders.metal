
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

struct InstanceInfo {
    float4x4 position;
};

vertex VertexOut vertex_shader(const VertexIn vertex_in [[stage_in]],
                               constant InstanceInfo *instances [[buffer(1)]],
                               uint instanceid [[instance_id]]) {
    VertexOut vertex_out;
    InstanceInfo info = instances[instanceid];
    vertex_out.position = info.position * vertex_in.position;
    
    vertex_out.color = float4( 1.0, 0.0, 0.0, 0.1 );
    return vertex_out;
}

fragment float4 fragment_shader(VertexOut vertex_in [[stage_in]]) {
    return vertex_in.color;
}
