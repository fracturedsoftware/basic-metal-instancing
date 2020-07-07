
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};


vertex VertexOut vertex_shader(const VertexIn vertex_in [[stage_in]],
                             uint instanceid [[instance_id]]) {
    VertexOut vertex_out;
    vertex_out.position = vertex_in.position;
    vertex_out.color = float4( 1.0, 0.0, 0.0, 1.0 );
    return vertex_out;
}

fragment float4 fragment_shader(VertexOut vertex_in [[stage_in]]) {
    return vertex_in.color;
}
