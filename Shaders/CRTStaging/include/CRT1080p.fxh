#ifndef _CRT_1080P_FXH
#define _CRT_1080P_FXH

#include "ReShade.fxh"
#include "Macros.fxh"
#include "Resolution.fxh"
#include "MaskWeights.fxh"

uniform float2 SpotSize <
    ui_label = "Spot Width / Height";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = float2(0.85, 0.80);

uniform float2 ScanlinesStrength <
    ui_label = "Scanlines Strength (Min / Max)";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = float2(0.80, 0.85);

uniform float2 ColorBoost <
    ui_label = "Color Boost (Even / Odd)";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 5.0;
    ui_step  = 0.01;
    ui_category = "CRT Emulation";
> = float2(2.5, 2.5);

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

// Macro for weights computing
#define WEIGHT(w) \
    if (w > 1.0) \
        w = 1.0; \
    w = 1.0 - w * w; \
    w = w * w;

float3 AddVGAOverlay(float3 color, float2 uv, float2 size)
{
    // scanlines
    float2 maskCoords = uv * size;

    float3 lumFactors = float3(0.2126, 0.7152, 0.0722);

    float luminance = dot(lumFactors, color);

    float evenOdd = floor(FMOD(maskCoords.y, 2.0));

    // dim factor (x = min, y = max)
    float dimFactor = lerp(1.0 - ScanlinesStrength.y,
                           1.0 - ScanlinesStrength.x,
                           luminance);

    float scanlineDim = clamp(evenOdd + dimFactor, 0.0, 1.0);

    color *= scanlineDim;

    // color boost (x = even, y = odd)
    color *= lerp(ColorBoost.x, ColorBoost.y, evenOdd);

    float saturation = lerp(1.2, 1.03, evenOdd);

    float l = length(color);
    color.r = pow(color.r + 1e-7, saturation);
    color.g = pow(color.g + 1e-7, saturation);
    color.b = pow(color.b + 1e-7, saturation);
    color   = normalize(color) * l;

    // mask
    color *= MaskWeights(maskCoords, MaskIntensity, PhosphorLayout);
    return color;
}

float3 CRT1080pSingleScan(sampler2D source, float2 uv, int2 targetSize)
{
    int2 sourceSize = tex2Dsize(source);

    float2 pixCoord = uv * sourceSize;
    float2 pixCenter = floor(pixCoord) + float2(0.5, 0.5);

    float2 tc = pixCenter / sourceSize;
    float3 color = GAMMA_IN(tex2D(source, tc).rgb);

    float dx = pixCoord.x - pixCenter.x;
    float hWeight00 = dx / SpotSize.x;
    WEIGHT(hWeight00);
    color *= hWeight00;

    // get closest horizontal neighbour to blend
    float2 offX;
    if (dx > 0.0) {
        offX = float2(1.0 / sourceSize.x, 0.0);
        dx   = 1.0 - dx;
    } else {
        offX = float2(-1.0 / sourceSize.x, 0.0);
        dx   = 1.0 + dx;
    }

    float3 colorNb = GAMMA_IN(tex2D(source, tc + offX).rgb);

    float hWeight01 = dx / SpotSize.x;
    WEIGHT(hWeight01);

    color = color + colorNb * hWeight01;

    // Vertical Blending
    float dy          = pixCoord.y - pixCenter.y;
    float vWeight00   = dy / SpotSize.y;
    WEIGHT(vWeight00);
    color *= vWeight00;

    // get closest vertical neighbour to blend
    float2 offY;
    if (dy > 0.0) {
        offY = float2(0.0, 1.0 / sourceSize.y);
        dy   = 1.0 - dy;
    } else {
        offY = float2(0.0, -1.0 / sourceSize.y);
        dy   = 1.0 + dy;
    }
    colorNb = GAMMA_IN(tex2D(source, tc + offY).rgb);

    float vWeight10 = dy / SpotSize.y;
    WEIGHT(vWeight10);

    color = color + colorNb * vWeight10 * hWeight00;

    colorNb = GAMMA_IN(tex2D(source, tc + offX + offY).rgb);

    color = color + colorNb * vWeight10 * hWeight01;

    color = AddVGAOverlay(color, uv, targetSize);

    return clamp(GAMMA_OUT(color), 0.0, 1.0);
}

float3 Tex2DLinear(sampler2D source, float2 uv)
{
    int2 sourceSize = tex2Dsize(source);

    // subtract 0.5 here and add it again after the floor to centre the texel
    float2 pixCoord = uv * sourceSize - float2(0.5, 0.5);

    float2 s0t0 = floor(pixCoord) + float2(0.5, 0.5);
    float2 s0t1 = s0t0 + float2(0.0, 1.0);
    float2 s1t0 = s0t0 + float2(1.0, 0.0);
    float2 s1t1 = s0t0 + float2(1.0, 1.0);

    float2 invSize = 1.0 / sourceSize;

    float3 c00 = GAMMA_IN(tex2D(source, s0t0 * invSize).rgb);
    float3 c01 = GAMMA_IN(tex2D(source, s0t1 * invSize).rgb);
    float3 c10 = GAMMA_IN(tex2D(source, s1t0 * invSize).rgb);
    float3 c11 = GAMMA_IN(tex2D(source, s1t1 * invSize).rgb);

    float2 weight = frac(pixCoord);

    float3 c0 = c00 + (c10 - c00) * weight.x;
    float3 c1 = c01 + (c11 - c01) * weight.x;

    return (c0 + (c1 - c0) * weight.y);
}

float3 CRT1080pDoubleScan(sampler2D source, float2 uv, int2 targetSize)
{
    int2 sourceSize = tex2Dsize(source);
    float2 prescale = ceil(GetViewportSize() / sourceSize);

    const float2 halfp  = float2(0.5, 0.5);

    float2 texel        = uv * sourceSize;
    float2 texelFloored = floor(texel);
    float2 s            = frac(texel);
    float2 regionRange  = halfp - halfp / prescale;
    float2 centerDist   = s - halfp;

    float2 f = (centerDist - clamp(centerDist, -regionRange, regionRange)) *
                prescale + halfp;

    float2 modTexel = min(texelFloored + f, sourceSize - halfp);
    float3 color    = Tex2DLinear(source, modTexel / sourceSize);

    color = AddVGAOverlay(color, uv, targetSize);

    return clamp(GAMMA_OUT(color), 0.0, 1.0);
}

float3 CRT1080p(sampler2D source, float2 uv, int2 targetSize)
{
    if (DoubleScan) {
        return CRT1080pDoubleScan(source, uv, targetSize);
    } else {
        return CRT1080pSingleScan(source, uv, targetSize);
    }
}

#endif // _CRT_1080P_FXH