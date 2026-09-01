#include "ReShade.fxh"
#include "include/Resolution.fxh"
#include "include/ImageAdjustments.fxh"
#include "include/CRTHyllian.fxh"

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

    return CRTHyllian(AdjustedImageSampler, viewportUV, viewportSize);
}

technique CRTHyllian
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
