#pragma once

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
    ui_label = "Color Temperature (Kelvin)";
    ui_type  = "drag";
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

uniform float RedGain <
    ui_label = "Red Gain";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 2.0;
    ui_step  = 0.01;
	ui_category = "Image Adjustments";
> = 1.0;

uniform float GreenGain <
    ui_label = "Green Gain";
    ui_type  = "drag";
    ui_min   = 0.0;
    ui_max   = 2.0;
    ui_step  = 0.01;
	ui_category = "Image Adjustments";
> = 1.0;

uniform float BlueGain <
    ui_label = "Blue Gain";
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

// Adapted from 'WinUaeColor.fx'
// https://github.com/guestrr/WinUAE-Shaders/
//
// Copyright (C) 2020 guest(r), Dr. Venom - guest.r@gmail.com

// Color profile transforms (sRGB to XYZ)

static const float3x3 sRGB_to_XYZ_sRGB = float3x3(
     0.412391,  0.357584,  0.180481,
     0.212639,  0.715169,  0.072192,
     0.019331,  0.119195,  0.950532
);

static const float3x3 sRGB_to_XYZ_Profile1 = float3x3(
     0.430554,  0.341550,  0.178352,
     0.222004,  0.706655,  0.071341,
     0.020182,  0.129553,  0.939322
);

static const float3x3 sRGB_to_XYZ_Profile2 = float3x3(
     0.396686,  0.372504,  0.181266,
     0.210299,  0.713766,  0.075936,
     0.006131,  0.115356,  0.967571
);

static const float3x3 sRGB_to_XYZ_Profile3 = float3x3(
     0.393521,  0.365258,  0.191677,
     0.212376,  0.701060,  0.086564,
     0.018739,  0.111934,  0.958385
);

static const float3x3 sRGB_to_XYZ_Profile4 = float3x3(
     0.392258,  0.351135,  0.166603,
     0.209410,  0.725680,  0.064910,
     0.016061,  0.093636,  0.850324
);

static const float3x3 sRGB_to_XYZ_Profile5 = float3x3(
     0.377923,  0.317366,  0.207738,
     0.195679,  0.722319,  0.082002,
     0.010514,  0.097826,  1.076960
);

// Colour space transforms (XYZ to linear RGB in target colour space)

static const float3x3 XYZ_to_sRGB = float3x3(
     3.240970, -1.537383, -0.498611,
    -0.969244,  1.875968,  0.041555,
     0.055630, -0.203977,  1.056972
);

static const float3x3 XYZ_to_DCI_P3 = float3x3(
     2.725394,  -1.018003,  -0.440163,
    -0.795168,   1.689732,   0.022647,
     0.041242,  -0.087639,   1.100929
);

static const float3x3 XYZ_to_DisplayP3 = float3x3(
     2.493497, -0.931384, -0.402711,
    -0.829489,  1.762664,  0.023625,
     0.035846, -0.076172,  0.956885
);

static const float3x3 XYZ_to_ModernP3 = float3x3(
     2.791723, -1.173165, -0.440973,
    -0.894766,  1.815586,  0.032000,
     0.041678, -0.130886,  1.002034
);

static const float3x3 XYZ_to_AdobeRGB = float3x3(
     2.041588, -0.565007, -0.344731,
    -0.969244,  1.875968,  0.041555,
     0.013444, -0.118362,  1.015175
);

static const float3x3 XYZ_to_Rec2020 = float3x3(
     1.716651, -0.355671, -0.253366,
    -0.666684,  1.616481,  0.015769,
     0.017640, -0.042771,  0.942103
);

float3 XYZ_to_Yxy(float3 XYZ)
{
	float XYZrgb = XYZ.r + XYZ.g + XYZ.b;
	float Yxyr   = XYZ.g;
	float Yxyg   = (XYZrgb <= 0.0) ? 0.3805 : XYZ.r / XYZrgb;
	float Yxyb   = (XYZrgb <= 0.0) ? 0.3769 : XYZ.g / XYZrgb;

	return float3(Yxyr, Yxyg, Yxyb);
}

float3 Yxy_to_XYZ(float3 Yxy)
{
	float Xs  = Yxy.r * (Yxy.g / Yxy.b);
	float Xsz = (Yxy.r <= 0.0) ? 0 : 1;
	float3 XYZ  = Xsz * float3(Xs, Yxy.r, (Xs / Yxy.g) - Xs - Yxy.r);

	return XYZ;
}

// Expects gamma-encoded color
float luminance(float3 x)
{
	return dot(x, float3(0.212656, 0.715158, 0.072186));
}

// Expects gamma-encoded color
float3 saturation(float3 color, float s)
{
    float lum = luminance(color);
	return clamp(lerp(lum, color, s + 1.0), 0.0, 1.0);
}

// Adaptred from Guest's 'pre-shaders-afterglow.slang'
// Copyright (C) 2019-2025 guest(r) and Dr. Venom
//
// Source: https://github.com/libretro/slang-shaders/blob/cf5c768ffda2520d4938df68d33fd63fff276c0c/crt/shaders/guest/advanced/pre-shaders-afterglow.slang
//
float3 plant(float3 tar, float r)
{
	float t = max(max(tar.r, tar.g), tar.b) + 0.00001;
	return tar * r / t;
}


// Expects gamma-encoded color
// Amount range: -2.0 to 2.0
float3 sigmoid_contrast(float3 color, float amount)
{
	float x = max(max(color.r, color.g), color.b);
	float c = max(lerp(x, smoothstep(0.0, 1.0, x), amount), 0.0);
	return plant(color, c);
}

// Adapted from `PR80_00_Base_Effects.fxh` by prod80 (Bas Veth)
// https://github.com/prod80/prod80-ReShade-Repository/
//
// MIT License, Copyright (c) 2020 prod80
//

// Expects gamma-encoded color
float3 rgb_to_hcv(float3 color)
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
float3 rgb_to_hsl(float3 color)
{
	color    = max(color, 0.000001);
	float3 hcv = rgb_to_hcv(color);
	float l  = hcv.z - hcv.y * 0.5;
	float s  = hcv.y / (1.0 - abs(l * 2.0 - 1.0) + 0.000001);
	return float3(hcv.x, s, l);
}

// Expects gamma-encoded color
float3 hue_to_rgb(float hue)
{
	return clamp(float3(abs(hue * 6.0 - 3.0) - 1.0,
	                    2.0 - abs(hue * 6.0 - 2.0),
	                    2.0 - abs(hue * 6.0 - 4.0)),
	             0.0,
	             1.0);
}

// Expects gamma-encoded color
float3 hsl_to_rgb(in float3 hsl)
{
	float3 color = hue_to_rgb(hsl.x);
	float c    = (1.0 - abs(2.0 * hsl.z - 1.0)) * hsl.y;
	return (color - 0.5f) * c + hsl.z;
}

// Expects gamma-encoded color
float3 kelvin_to_rgb(int k)
{
	float3 ret;
	float kelvin = clamp(k, 1000.0f, 40000.0f) / 100.0f;

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
float3 color_temperature(float3 color, int kelvin, float luma_preserve)
{
	float orig_luma = rgb_to_hsl(color).z;
	color *= kelvin_to_rgb(kelvin);
	float3 color2 = hsl_to_rgb(float3(rgb_to_hsl(color).xy, orig_luma));

	return lerp(color, color2, luma_preserve);
}

// Adapted from Dogway's 'pre-shaders-afterglow-grade.slang'
// Copyright (C) 2020-2023 Dogway (Jose Linares)
//
// Source: https://github.com/libretro/slang-shaders/blob/cf5c768ffda2520d4938df68d33fd63fff276c0c/crt/shaders/guest/advanced/grade/pre-shaders-afterglow-grade.slang
//
float eotf_1886a(float color, float bl, float brightness, float contrast)
{
	const float wl = 100.0;

	float b = pow(bl, 1.0 / 2.4);
	float a = pow(wl, 1.0 / 2.4) - b;

	// Convert range to -0.20 to +0.20
	b = (brightness - 50.0) / 250. + b / a;

	// Convert range to 0.50 to +2.00
	a = contrast != 50.0 ? pow(2.0, (contrast - 50.0) / 50.0) : 1.0;

	const float Vc = 0.35;           // offset
	float Lw       = wl / 100.0 * a; // white level
	float Lb       = min(b * a, Vc); // black level
	const float a1 = 2.6;            // shoulder gamma
	const float a2 = 3.0;            // knee gamma

	float k = Lw / pow(1.0 + Lb, a1);

	// Slope for knee gamma
	float sl = k * pow(Vc + Lb, a1 - a2);

	color = color >= Vc ? k * pow(color + Lb, a1) : sl * pow(color + Lb, a2);

	// Black lift compensation
	float bc = 0.00446395 * pow(bl, 1.23486);

	// Undo black lift
	color = min(max(color - bc, 0.0) * (1.0 / (1.0 - bc)), 1.0);

	// Restore gamma from 'undo black lift'
	color = pow(color, 1.0 - 0.00843283 * pow(bl, 1.22744));

	return color;
}

// Expects gamma-encoded color
float3 eotf_1886a(float3 color, float black_level, float brightness, float contrast)
{
	color.r = eotf_1886a(color.r,
						 black_level,
	                     brightness,
	                     contrast);

	color.g = eotf_1886a(color.g,
	                     black_level,
	                     brightness,
	                     contrast);

	color.b = eotf_1886a(color.b,
	                     black_level,
	                     brightness,
	                     contrast);

	return color.rgb;
}

// Precomputed
static const float CrtBlackLevel = 0.03816404522830565;

float3 ImageAdjustments(sampler2D source, float2 uv)
{
	float3 color = tex2D(source, uv).rgb;
	
    color = sigmoid_contrast(color, DigitalContrast);
	color = max(color, BlackLevelBoost * BlackLevelColor);
	color = saturation(color, Saturation);
	color = color_temperature(color,
	                          ColorTemperatureK,
	                          ColorTemperatureLumaPreserve);

	// Color space (default sRGB) & color profile transforms (default none)
	float baseGamma = 2.2;
	float3x3 colorSpaceTransform = XYZ_to_sRGB;
	float3x3 colorProfileTransform = sRGB_to_XYZ_sRGB;

	if      (ColorSpace	== 1) { baseGamma = 2.6; colorSpaceTransform = XYZ_to_DCI_P3;    } // DCI-P3, DCI whitepoint
	else if (ColorSpace == 2) { baseGamma = 2.6; colorSpaceTransform = XYZ_to_DisplayP3; } // DCI-P3, D65 whitepoint
	else if (ColorSpace == 3) { baseGamma = 2.2; colorSpaceTransform = XYZ_to_DisplayP3; } // Display P3, D65 whitepoint
	else if (ColorSpace == 4) { baseGamma = 2.2; colorSpaceTransform = XYZ_to_ModernP3;  } // Modern DCI-P3
	else if (ColorSpace == 5) { baseGamma = 2.2; colorSpaceTransform = XYZ_to_AdobeRGB;  } // Adobe RGB
	else if (ColorSpace == 6) { baseGamma = 2.4; colorSpaceTransform = XYZ_to_Rec2020;   } // Rec 2020

	if      (CrtColorProfile == 1) { colorProfileTransform = sRGB_to_XYZ_Profile1; } // EBU
	else if (CrtColorProfile == 2) { colorProfileTransform = sRGB_to_XYZ_Profile2; } // P22
	else if (CrtColorProfile == 3) { colorProfileTransform = sRGB_to_XYZ_Profile3; } // SMPTE C
	else if (CrtColorProfile == 4) { colorProfileTransform = sRGB_to_XYZ_Profile4; } // Philips
	else if (CrtColorProfile == 5) { colorProfileTransform = sRGB_to_XYZ_Profile5; } // Trinitron
	
    // sRGB => linear RGB
	// The colour profiles are correct when using 2.2 gamma
	color = pow(color, 2.2);

	// linear RGB => XYZ (with optional color profile transform)
	color = mul(colorProfileTransform, color);

	// XYZ => linear RGB
	color = mul(colorSpaceTransform, color);
	
	// Use the square of the input params to achieve roughly perceptual linear
	// taper (that's close enough to ~2.2 gamma)
	color *= float3(RedGain * RedGain, 
                    GreenGain * GreenGain, 
                    BlueGain * BlueGain);
	
	// linear RGB => gamma-encoded output space
	color = pow(color, 1.0 / 2.2);
	
	// gamma-encoded output space => linear RGB via CRT EOTF
	// (Electro-Optical Transform Function)
	//
	// This transform to display referred linear and undoes developer-baked
	// CRT gamma (from 2.40 at default 0.1 CRT black level, to 2.60 at 0.0 CRT
	// black level).
	color = eotf_1886a(color, CrtBlackLevel, Brightness, Contrast);
	
	// linear RGB => gamma-encoded output space
	//
	// We needed this extra gamma encode/decode roundtrip because applying the
	// CRT EOTF before the colour profile transforms would result in too
	// saturated colours.
	color = pow(color, 1.0 / (baseGamma + Gamma));
	
    return color;
}