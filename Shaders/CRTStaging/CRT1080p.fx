#include "ReShade.fxh"
#include "include/Resolution.fxh"
#include "include/ImageAdjustments.fxh"
#include "include/CRT1080p.fxh"

texture2D BackBufferTexture : COLOR;

sampler2D BackBufferSampler
{
    Texture = BackBufferTexture;
    MagFilter = POINT;
    MinFilter = POINT;
    MipFilter = POINT;
};

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
    #if ENABLE_DOWNSCALE
        int2 imageSize = OriginalSize;
    #else
        int2 imageSize = tex2Dsize(AdjustedImageSampler);
    #endif

    float2 bufferUV = ToBufferUV(adjustedImageUV, imageSize);

    return ImageAdjustments(BackBufferSampler, bufferUV);
}

float3 CRTEmulationPS(float2 bufferUV : TEXCOORD) : SV_Target
{
    int2 viewportSize = GetViewportSize();
    float2 viewportUV = FromBufferUV(bufferUV, viewportSize);

    if (any(viewportUV < 0.0) || any(viewportUV > 1.0))
        discard;

    return CRT1080p(AdjustedImageSampler, viewportUV, viewportSize);
}

technique CRT1080p
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
