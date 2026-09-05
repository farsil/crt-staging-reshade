#ifndef _IMAGE_ADJUSTMENTS_FXH
#define _IMAGE_ADJUSTMENTS_FXH

uniform float Saturation <
    ui_label = "Saturation";
    ui_type  = "drag";
    ui_min   = -1.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 0.0;

uniform float DigitalContrast <
    ui_label = "Digital Contrast";
    ui_type  = "drag";
    ui_min   = -2.0;
    ui_max   = 2.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 0.0;

uniform int ColorTemperatureK <
    ui_label = "Color Temperature";
    ui_type  = "drag";
    ui_units  = " K";
    ui_min   = 3000;
    ui_max   = 10000;
    ui_step  = 10;
    ui_category = "Image Adjustments";
> = 6500;

uniform float ColorTemperatureLumaPreserve <
    ui_label = "Color Temperature Luma Preserve";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 0.0;

static const float3 BlackLevelColor = 0.16;

uniform float BlackLevelBoost <
    ui_label = "Black Level Boost";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 0.0;

uniform int ColorSpace <
    ui_label = "Color Space";
    ui_type = "combo";
    ui_items = "sRGB\0"
               "DCI-P3\0"
               "DCI-P3 D65\0"
               "Display P3\0"
               "Modern DCI-P3\0"
               "Adobe RGB 2020\0"
               "Rec.2020\0";
    ui_category = "Image Adjustments";
> = 0;

uniform int CrtColorProfile <
    ui_label = "CRT Color Profile";
    ui_type = "combo";
    ui_items = "None\0"
               "EBU\0"
               "P22\0"
               "SMPTE C\0"
               "Philips\0"
               "Trinitron\0";
    ui_category = "Image Adjustments";
> = 2;

uniform float3 ColorGain <
    ui_label = "Color Gain (R / G / B)";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 2.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 1.0;

uniform float Brightness <
    ui_label = "Brightness";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 100.0;
    ui_step  = 1.0;
    ui_category = "Image Adjustments";
> = 45.0;

uniform float Contrast <
    ui_label = "Contrast";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 100.0;
    ui_step  = 1.0;
    ui_category = "Image Adjustments";
> = 65.0;

uniform float Gamma <
    ui_label = "Gamma";
    ui_type  = "drag";
    ui_min   = -1.0;
    ui_max   = 1.0;
    ui_step  = 0.01;
    ui_category = "Image Adjustments";
> = 0.0;

// Color profile transforms (sRGB to XYZ)
float3x3 GetColorProfileTransform(int crtProfile) {
    switch (crtProfile) {
        case 1: // EBU
            return float3x3(
                 0.430554,  0.341550,  0.178352,
                 0.222004,  0.706655,  0.071341,
                 0.020182,  0.129553,  0.939322
            );
        case 2: // P22
            return float3x3(
                 0.396686,  0.372504,  0.181266,
                 0.210299,  0.713766,  0.075936,
                 0.006131,  0.115356,  0.967571
            );
        case 3: // SMPTE C
            return float3x3(
                 0.393521,  0.365258,  0.191677,
                 0.212376,  0.701060,  0.086564,
                 0.018739,  0.111934,  0.958385
            );
        case 4: // Philips
            return float3x3(
                 0.392258,  0.351135,  0.166603,
                 0.209410,  0.725680,  0.064910,
                 0.016061,  0.093636,  0.850324
            );
        case 5: // Trinitron
            return float3x3(
                 0.377923,  0.317366,  0.207738,
                 0.195679,  0.722319,  0.082002,
                 0.010514,  0.097826,  1.076960
            );
        default: // None
            return float3x3(
                 0.412391,  0.357584,  0.180481,
                 0.212639,  0.715169,  0.072192,
                 0.019331,  0.119195,  0.950532
            );
    }
}

// Colour space transforms (XYZ to linear RGB in target colour space)
float3x3 GetColorSpaceTransform(int colorSpace) {
    switch (colorSpace) {
        case 1: // DCI-P3
            return float3x3(
                 2.725394,  -1.018003,  -0.440163,
                -0.795168,   1.689732,   0.022647,
                 0.041242,  -0.087639,   1.100929
            );
        case 2: // DCI-P3 D65
        case 3: // Display P3
            return float3x3(
                 2.493497, -0.931384, -0.402711,
                -0.829489,  1.762664,  0.023625,
                 0.035846, -0.076172,  0.956885
            );
        case 4: // Modern DCI-P3
            return float3x3(
                 2.791723, -1.173165, -0.440973,
                -0.894766,  1.815586,  0.032000,
                 0.041678, -0.130886,  1.002034
            );
        case 5: // Adobe RGB 2020
            return float3x3(
                 2.041588, -0.565007, -0.344731,
                -0.969244,  1.875968,  0.041555,
                 0.013444, -0.118362,  1.015175
            );
        case 6: // Rec.2020
            return float3x3(
                 1.716651, -0.355671, -0.253366,
                -0.666684,  1.616481,  0.015769,
                 0.017640, -0.042771,  0.942103
            );
        default:
            return float3x3(
                 3.240970, -1.537383, -0.498611,
                -0.969244,  1.875968,  0.041555,
                 0.055630, -0.203977,  1.056972
            );
    }
}

float GetBaseGamma(int colorSpace) {
    switch (colorSpace) {
        case 1: // DCI-P3
        case 2: // DCI-P3 D65
            return 2.6;
        case 6: // Rec 2020
            return 2.4;
        default:
            return 2.2;
    }

}

// Expects gamma-encoded color
float Luminance(float3 color)
{
    return dot(color, float3(0.212656, 0.715158, 0.072186));
}

float3 Plant(float3 tar, float r)
{
    float t = max(max(tar.r, tar.g), tar.b) + 0.00001;
    return tar * r / t;
}


// Expects gamma-encoded color
// Amount range: -2.0 to 2.0
float3 SigmoidContrast(float3 color, float amount)
{
    float x = max(max(color.r, color.g), color.b);
    float c = max(lerp(x, smoothstep(0.0, 1.0, x), amount), 0.0);
    return Plant(color, c);
}

// Expects gamma-encoded color
float3 RGBToHCV(float3 color)
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 p = (color.g < color.b) ? float4(color.bg, -1.0, 2.0 / 3.0)
                                   : float4(color.gb, 0.0, -1.0 / 3.0);

    float4 q1 = (color.r < p.x) ? float4(p.xyw, color.r) : float4(color.r, p.yzx);
    float c = q1.x - min(q1.w, q1.y);
    float h = abs((q1.w - q1.y) / (6.0 * c + 0.000001) + q1.z);
    return float3(h, c, q1.x);
}

// Expects gamma-encoded color
float3 RGBToHSL(float3 color)
{
    color    = max(color, 0.000001);
    float3 hcv = RGBToHCV(color);
    float l  = hcv.z - hcv.y * 0.5;
    float s  = hcv.y / (1.0 - abs(l * 2.0 - 1.0) + 0.000001);
    return float3(hcv.x, s, l);
}

// Expects gamma-encoded color
float3 HueToRGB(float hue)
{
    return clamp(float3(abs(hue * 6.0 - 3.0) - 1.0,
                        2.0 - abs(hue * 6.0 - 2.0),
                        2.0 - abs(hue * 6.0 - 4.0)),
                 0.0,
                 1.0);
}

// Expects gamma-encoded color
float3 HSLToRGB(float3 hsl)
{
    float3 color = HueToRGB(hsl.x);
    float c    = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
    return (color - 0.5f) * c + hsl.z;
}

// Expects gamma-encoded color
float3 KelvinToRGB(int temperature)
{
    float3 ret;
    float kelvin = clamp(temperature, 1000.0f, 40000.0f) / 100.0f;

    if (kelvin <= 66.0f) {
        ret.r = 1.0f;
        ret.g = clamp(0.39008157876901960784f * log(kelvin) -
                              0.63184144378862745098f,
                      0.0,
                      1.0);

    } else {
        float t = max(kelvin - 60.0f, 0.0f);

        ret.r = clamp(1.29293618606274509804f * pow(t, -0.1332047592f),
                      0.0,
                      1.0);

        ret.g = clamp(1.12989086089529411765f * pow(t, -0.0755148492f),
                      0.0,
                      1.0);
    }

    if (kelvin >= 66.0f) {
        ret.b = 1.0f;
    } else if (kelvin < 19.0f) {
        ret.b = 0.0f;
    } else {
        ret.b = clamp(0.54320678911019607843f * log(kelvin - 10.0f) -
                              1.19625408914f,
                      0.0,
                      1.0);
    }
    return ret;
}

// Expects gamma-encoded color
float3 ColorTemperature(float3 color, int kelvin, float luma_preserve)
{
    float orig_luma = RGBToHSL(color).z;
    color *= KelvinToRGB(kelvin);
    float3 color2 = HSLToRGB(float3(RGBToHSL(color).xy, orig_luma));

    return lerp(color, color2, luma_preserve);
}

float EOTF1886A(float color, float blackLevel, float brightness, float contrast)
{
    const float whiteLevel = 100.0;

    float b = pow(blackLevel, 1.0 / 2.4);
    float a = pow(whiteLevel, 1.0 / 2.4) - b;

    // Convert range to -0.20 to +0.20
    b = (brightness - 50.0) / 250. + b / a;

    // Convert range to 0.50 to +2.00
    a = contrast != 50.0 ? pow(2.0, (contrast - 50.0) / 50.0) : 1.0;

    const float vc = 0.35;                   // offset
    float lw       = whiteLevel / 100.0 * a; // white level
    float lb       = min(b * a, vc);         // black level
    const float a1 = 2.6;                    // shoulder gamma
    const float a2 = 3.0;                    // knee gamma

    float k = lw / pow(1.0 + lb, a1);

    // Slope for knee gamma
    float sl = k * pow(vc + lb, a1 - a2);

    color = color >= vc ? k * pow(color + lb, a1) : sl * pow(color + lb, a2);

    // Black lift compensation
    float bc = 0.00446395 * pow(blackLevel, 1.23486);

    // Undo black lift
    color = min(max(color - bc, 0.0) * (1.0 / (1.0 - bc)), 1.0);

    // Restore gamma from 'undo black lift'
    color = pow(color, 1.0 - 0.00843283 * pow(blackLevel, 1.22744));

    return color;
}

// Expects gamma-encoded color
float3 EOTF1886A(float3 color, float blackLevel, float brightness, float contrast)
{
    return float3(
        EOTF1886A(color.r, blackLevel, brightness, contrast),
        EOTF1886A(color.g, blackLevel, brightness, contrast),
        EOTF1886A(color.b, blackLevel, brightness, contrast)
    );
}

// Precomputed
static const float CrtBlackLevel = 0.03816404522830565;

float3 ImageAdjustments(sampler2D source, float2 uv)
{
    float3 color = tex2D(source, uv).rgb;

    color = SigmoidContrast(color, DigitalContrast);
    color = max(color, BlackLevelBoost * BlackLevelColor);
    color = clamp(lerp(Luminance(color), color, Saturation + 1.0), 0.0, 1.0);
    color = ColorTemperature(color,
                             ColorTemperatureK,
                             ColorTemperatureLumaPreserve);

    // sRGB => linear RGB
    // The colour profiles are correct when using 2.2 gamma
    color = pow(color, 2.2);

    // linear RGB => XYZ (with optional color profile transform)
    color = mul(GetColorProfileTransform(CrtColorProfile), color);

    // XYZ => linear RGB
    color = mul(GetColorSpaceTransform(ColorSpace), color);

    // Use the square of the input params to achieve roughly perceptual linear
    // taper (that's close enough to ~2.2 gamma)
    color *= ColorGain * ColorGain;

    // linear RGB => gamma-encoded output space
    color = pow(color, 1.0 / 2.2);

    // gamma-encoded output space => linear RGB via CRT EOTF
    // (Electro-Optical Transform Function)
    //
    // This transform to display referred linear and undoes developer-baked
    // CRT gamma (from 2.40 at default 0.1 CRT black level, to 2.60 at 0.0 CRT
    // black level).
    color = EOTF1886A(color, CrtBlackLevel, Brightness, Contrast);

    // linear RGB => gamma-encoded output space
    //
    // We needed this extra gamma encode/decode roundtrip because applying the
    // CRT EOTF before the colour profile transforms would result in too
    // saturated colours.
    color = pow(color, 1.0 / (GetBaseGamma(ColorSpace) + Gamma));

    return color;
}

#endif // _IMAGE_ADJUSTMENTS_FXH