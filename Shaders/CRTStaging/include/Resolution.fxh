#ifndef _RESOLUTION_FXH
#define _RESOLUTION_FXH

#include "ReShade.fxh"

#ifndef SOURCE_WIDTH
    #define SOURCE_WIDTH 320
#endif

#ifndef SOURCE_HEIGHT
    #define SOURCE_HEIGHT 200
#endif

#ifndef ENABLE_DOWNSCALE
    #define ENABLE_DOWNSCALE 0
#endif

#if ENABLE_DOWNSCALE
    uniform int2 OriginalSize <
        ui_label = "Original Size";
        ui_type  = "drag";
        ui_min   = 0.0;
        ui_max   = int2(BUFFER_WIDTH, BUFFER_HEIGHT);
        ui_step  = 1;
        ui_category = "Resolution";
    > = int2(SOURCE_WIDTH, SOURCE_HEIGHT);
#endif

uniform int2 SourceSize <
    ui_label = "Source Size";
    ui_type  = "drag";
    ui_tooltip = "Must be set via preprocessor definitions";
    ui_category = "Resolution";
    noedit = true;
    nosave = true;
    noreset = true;
> = int2(SOURCE_WIDTH, SOURCE_HEIGHT);

uniform int UpscalingStrategy <
    ui_label = "Upscaling Strategy";
    ui_type = "combo";
    ui_items = "Y Fill\0"
               "Y Integer\0"
               "XY Integer\0";
    ui_category = "Resolution";
> = 1;

uniform bool DoubleScan <
    ui_label = "Double Scan";
    ui_type  = "radio";
    ui_category = "Resolution";
> = false;

static const float2 CenterUV = 0.5;
static const float CorrectAspectRatio = 4.0 / 3.0;

int2 GetViewportSize()
{
    int2 size = 0;

    if (UpscalingStrategy == 0) {
        size.y = BUFFER_HEIGHT;
        size.x = round(size.y * CorrectAspectRatio / 2) * 2;
    } else if (UpscalingStrategy == 1) {
        size.y = SOURCE_HEIGHT * floor(BUFFER_HEIGHT / SOURCE_HEIGHT);
        size.x = round(size.y * CorrectAspectRatio / 2) * 2;
    } else if (UpscalingStrategy == 2) {
        size.y = SOURCE_HEIGHT * floor(BUFFER_HEIGHT / SOURCE_HEIGHT);
        size.x = round(CorrectAspectRatio * size.y / SOURCE_WIDTH) * SOURCE_WIDTH;
    }

    return size;
}

float2 FromBufferUV(float2 uv, int2 size)
{
    float2 sizeUV = size / BUFFER_SCREEN_SIZE;
    float2 minUV = CenterUV - 0.5 * sizeUV;
    return (uv - minUV) / sizeUV;
}

float2 ToBufferUV(float2 uv, int2 size)
{
    float2 sizeUV = size / BUFFER_SCREEN_SIZE;
    float2 minUV = CenterUV - 0.5 * sizeUV;
    return (uv * sizeUV) + minUV;
}

#endif // _RESOLUTION_FXH