#ifndef _RESOLUTION_FXH
#define _RESOLUTION_FXH

#ifndef SOURCE_WIDTH
    #define SOURCE_WIDTH 320
#endif

#ifndef SOURCE_HEIGHT
    #define SOURCE_HEIGHT 200
#endif

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