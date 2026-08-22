#include "ReShade.fxh"
#include "SizeHelpers.fxh"
#include "ImageAdjustments.fxh"

#if BUFFER_HEIGHT > 1080
	#include "CRTHyllian.fxh"
	#define CRT_EMULATION CRTHyllian
#else
	#include "CRT1080p.fxh"
	#define CRT_EMULATION CRT1080p
#endif

texture2D AdjustedImageTexture
{
	Width = SOURCE_WIDTH;
	Height = SOURCE_HEIGHT;
};

sampler2D AdjustedImageSampler
{
	Texture = AdjustedImageTexture;
	MagFilter = POINT;
	MinFilter = POINT;
	MipFilter = POINT;
};

float3 ImageAdjustmentsPS(float2 adjustedImageUV : TEXCOORD) : SV_Target
{
	float2 bufferUV = ToBufferUV(adjustedImageUV, tex2Dsize(AdjustedImageSampler));
   
    return ImageAdjustments(ReShade::BackBuffer, bufferUV);
}

float3 CRTEmulationPS(float2 bufferUV : TEXCOORD) : SV_Target
{	
	int2 viewportSize = GetViewportSize();
	float2 viewportUV = FromBufferUV(bufferUV, viewportSize);
	
	if (any(viewportUV < 0.0) || any(viewportUV > 1.0))
		discard;
		
	return CRT_EMULATION(AdjustedImageSampler, viewportUV, viewportSize);
}

technique CrtStaging
{
   pass ImageAdjustments
   {
      VertexShader = PostProcessVS;
      PixelShader  = ImageAdjustmentsPS;
	  RenderTarget = AdjustedImageTexture;
   }

   pass CrtEmulation
   {
      VertexShader = PostProcessVS;
      PixelShader  = CRTEmulationPS;
   }
}