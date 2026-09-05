#ifndef _CRT_HYLLIAN_FXH
#define _CRT_HYLLIAN_FXH

#include "ReShade.fxh"
#include "Macros.fxh"
#include "Resolution.fxh"
#include "MaskWeights.fxh"

uniform float ScanlinesStrength <
    ui_label = "Scanlines Strength";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 0.75;

uniform float2 BeamWidth <
    ui_label = "Beam Width (Min / Max)";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 2.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = float2(1.0, 1.20);

uniform float ColorBoost <
    ui_label = "Color Boost";
    ui_type  = "drag";
    ui_min   = 1.0;
    ui_max   = 4.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 2.5;

uniform int PhosphorLayout <
    ui_label = "Phosphor Layout";
    ui_type  = "drag";
    ui_min   = 0;
    ui_max   = 19;
    ui_step  = 1;
    ui_category = "CRT Emulation";
> = 0;

uniform float MaskIntensity <
    ui_label = "Mask Intensity";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 0.55;

uniform float InputGamma <
    ui_label = "Input Gamma";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 5.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 2.4;

uniform float OutputGamma <
    ui_label = "Output Gamma";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 5.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 2.48;

uniform float AntiRinging <
    ui_label = "Anti Ringing";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = 1.0;

uniform int HorizontalFilter <
    ui_label = "Horizontal Filter";
    ui_type  = "combo";
    ui_items = "Hermite\0"
               "Cubic B-Spline\0"
               "Catmull-Rom\0"
               "Mitchell-Netravali\0"
               "Robidoux\0"
               "Robidoux Sharp\0";
    ui_category = "CRT Emulation";
> = 0;

uniform bool VerticalScanlines <
    ui_label = "Vertical Scanlines";
    ui_type  = "radio";
    ui_category = "CRT Emulation";
> = false;

// Horizontal cubic filter.
float4x4 GetHFilter()
{
    float B = 0.0;
    float C = 0.0;

    if (HorizontalFilter == 1) { B = 1.0; C = 0.0; }       // Cubic B-Spline
    if (HorizontalFilter == 2) { B = 0.0; C = 0.5; }       // Catmull-Rom
    if (HorizontalFilter == 3) { B = 0.3333; C = 0.3333; } // Mitchell-Netravali
    if (HorizontalFilter == 4) { B = 0.3782; C = 0.3109; } // Robidoux
    if (HorizontalFilter == 5) { B = 0.2620; C = 0.3690; } // Robidoux Sharp

    return float4x4(
        (-B - 6.0*C)/6.0,            (3.0*B + 12.0*C)/6.0,         (-3.0*B - 6.0*C)/6.0,             B/6.0,
        (12.0 - 9.0*B - 6.0*C)/6.0,  (-18.0 + 12.0*B + 6.0*C)/6.0,                  0.0, (6.0 - 2.0*B)/6.0,
        (-12.0 + 9.0*B + 6.0*C)/6.0, (18.0 - 15.0*B - 12.0*C)/6.0,  (3.0*B + 6.0*C)/6.0,             B/6.0,
        (B + 6.0*C)/6.0,                                       -C,                  0.0,               0.0
    );
}

float3 CRTHyllian(sampler2D source, float2 uv, int2 size)
{
    int2 sourceSize = tex2Dsize(source);

    float2 sourceResolution = sourceSize * (1.0 + DoubleScan);

    float2 dx = lerp(float2(1.0 / sourceResolution.x, 0.0),
                     float2(0.0, 1.0 / sourceResolution.y),
                     VerticalScanlines);

    float2 dy = lerp(float2(0.0, 1.0 / sourceResolution.y),
                     float2(1.0 / sourceResolution.x, 0.0),
                     VerticalScanlines);

    float2 pixCoord = uv * sourceResolution + float2(-0.5, 0.5);

    float2 tc = lerp((floor(pixCoord) + float2(0.5,  0.5)) / sourceResolution,
                     (floor(pixCoord) + float2(1.0, -0.5)) / sourceResolution,
                     VerticalScanlines);

    float2 fp = lerp(frac(pixCoord), frac(pixCoord.yx), VerticalScanlines);

    float3 c00 = GAMMA_IN(tex2D(source, tc - dx     - dy));
    float3 c01 = GAMMA_IN(tex2D(source, tc          - dy));
    float3 c02 = GAMMA_IN(tex2D(source, tc + dx     - dy));
    float3 c03 = GAMMA_IN(tex2D(source, tc + 2.0*dx - dy));

    float3 c10 = GAMMA_IN(tex2D(source, tc     - dx));
    float3 c11 = GAMMA_IN(tex2D(source, tc         ));
    float3 c12 = GAMMA_IN(tex2D(source, tc     + dx));
    float3 c13 = GAMMA_IN(tex2D(source, tc + 2.0*dx));

    float4x3 colorMatrix0 = float4x3(c00, c01, c02, c03);
    float4x3 colorMatrix1 = float4x3(c10, c11, c12, c13);

    float4 hFilterPx  = mul(GetHFilter(), float4(fp.x*fp.x*fp.x, fp.x*fp.x, fp.x, 1.0));
    float3 color0     = mul(hFilterPx, colorMatrix0);
    float3 color1     = mul(hFilterPx, colorMatrix1);

    // Get min/max samples
    float3 minSample0 = min(c01, c02);
    float3 maxSample0 = max(c01, c02);
    float3 minSample1 = min(c11, c12);
    float3 maxSample1 = max(c11, c12);

    // Anti-ringing
    float3 aux = color0;
    color0   = clamp(color0, minSample0, maxSample0);
    color0   = lerp(aux, color0, AntiRinging * step(0.0, (c00 - c01) * (c02 - c03)) );

    aux      = color1;
    color1   = clamp(color1, minSample1, maxSample1);
    color1   = lerp(aux, color1, AntiRinging * step(0.0, (c10 - c11) * (c12 - c13)));

    float pos0 = fp.y;
    float pos1 = 1.0 - fp.y;

    float3 lum0 = lerp(float3(BeamWidth.x, BeamWidth.x, BeamWidth.x),
                       float3(BeamWidth.y, BeamWidth.y, BeamWidth.y),
                       color0);

    float3 lum1 = lerp(float3(BeamWidth.x, BeamWidth.x, BeamWidth.x),
                       float3(BeamWidth.y, BeamWidth.y, BeamWidth.y),
                       color1);

    float3 d0 = 4.0 * ScanlinesStrength * pos0 / (lum0 + 0.0000001);
    float3 d1 = 4.0 * ScanlinesStrength * pos1 / (lum1 + 0.0000001);

    d0 = exp(-d0 * d0);
    d1 = exp(-d1 * d1);

    float3 color = ColorBoost * (color0 * d0 + color1 * d1);

    // Mask
    float2 maskCoords = uv * size;
    maskCoords        = lerp(maskCoords.xy, maskCoords.yx, VerticalScanlines);
    color.rgb         *= MaskWeights(maskCoords, MaskIntensity, PhosphorLayout);

    // Output gamma
    return clamp(GAMMA_OUT(color), 0.0, 1.0);
}

#endif // _CRT_HYLLIAN_FXH