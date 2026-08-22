#pragma once

#include "ReShade.fxh"

#ifndef SOURCE_WIDTH
	#define SOURCE_WIDTH 320
#endif

#ifndef SOURCE_HEIGHT 
	#define SOURCE_HEIGHT 200
#endif

static const float2 CenterUV = 0.5;

int2 GetViewportSize()
{
#if BUFFER_WIDTH > BUFFER_HEIGHT
	int viewportHeight = int(SOURCE_HEIGHT * 
							 floor(BUFFER_HEIGHT / SOURCE_HEIGHT));
	int viewportWidth  = int(round(viewportHeight * 4.0 / 3.0));
#else
	int viewportWidth  = int(SOURCE_WIDTH * 
							 floor(BUFFER_WIDTH / SOURCE_WIDTH));
	int viewportHeight = int(round(viewportWidth * 3.0 / 4.0));
#endif
	
	return int2(viewportWidth, viewportHeight);
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