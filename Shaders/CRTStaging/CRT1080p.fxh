#pragma once

#include "ReShade.fxh"
#include "MaskWeights.fxh"

float3 CRT1080p(sampler2D source, float2 uv, int2 targetSize)
{
	return tex2D(source, uv).rgb;
}