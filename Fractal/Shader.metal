//
//  Shader.metal
//  metalFirstApp
//
//  Created by Мишаня on 13/04/2019.
//  Copyright © 2019 Мишаня. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Constants
{
    float deltaX;
    float deltaY;
    float zoom;
};

struct VertexIn
{
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut
{
    float4 position [[position]]; // tells the restarizer that this property will be responsible for the position
    float4 color;
};

half4 fractal_cumpute(float2 position, float2 translation, float zoom)
{
    float y = position.y;
    float x = position.x;
    
    float newRe, newIm, oldRe, oldIm;
    float pr, pi;
    float3 result_color;
    
    pr = (x - 320) / (320 * zoom) - translation.x - 0.4;//+ -0.5 + transform->delta_x;// man_struct->man_delta_x;
    pi = (y - 568) / (320 * zoom) - translation.y;// + 0 + transform->delta_y; //man_struct->man_delta_y;
    newRe = newIm = oldRe = oldIm = 0;
    int i = 0;
    while (i++ < 250)
    {
        oldRe = newRe;
        oldIm = newIm;
        newRe = oldRe * oldRe - oldIm * oldIm + pr;
        newIm = 2 * oldRe * oldIm + pi;
        if ((newRe * newRe + newIm * newIm) > 4)
            break;
    }
    result_color.r = (i % 250) / 250.0;
    result_color.g = (i % 250) / 250.0;
    result_color.b = (i % 250) / 250.0;
    
    return half4(half3(result_color), 1);
}

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]])
{
    
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    if (vertexIn.position.y < -vertexIn.position.x)
        vertexOut.color = float4(0, 0, 0, 1);
    else
        vertexOut.color = vertexIn.color;
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]],
                              constant Constants &constants [[buffer(0)]])
{
    half4 result_color;
    float2 translation;
    
    translation = float2(constants.deltaX, constants.deltaY);
    result_color = fractal_cumpute(vertexIn.position.xy, translation, constants.zoom);
    //return half4(vertexIn.color);
    return result_color;
}



