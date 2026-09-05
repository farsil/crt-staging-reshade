#ifndef _MASK_WEIGHTS_FXH
#define _MASK_WEIGHTS_FXH

#include "ReShade.fxh"
#include "Macros.fxh"

float3 MaskWeights(float2 coord, float maskIntensity, int phosphorLayout)
{
    float3 weights = 1.0;

    float on = 1.0;
    float off = 1.0 - maskIntensity;

    float3 red     = float3(on,  off, off);
    float3 green   = float3(off, on,  off);
    float3 blue    = float3(off, off, on );
    float3 magenta = float3(on,  off, on );
    float3 yellow  = float3(on,  on,  off);
    float3 cyan    = float3(off, on,  on );
    float3 black   = float3(off, off, off);
    float3 white   = float3(on,  on,  on );

    int w, z = 0;

    // This pattern is used by a few layouts, so we'll define it here
    float3 apertureWeights = lerp(magenta, green, floor(FMOD(coord.x, 2.0)));

    if (phosphorLayout == 0) {
        return weights;
    }
    else if (phosphorLayout == 1) {
        // classic aperture for RGB panels; good for 1080p, too small for 4K+
        // aka aperture_1_2_bgr
        weights = apertureWeights;
        return weights;
    }
    else if (phosphorLayout == 2) {
        // 2x2 shadow mask for RGB panels; good for 1080p, too small for 4K+
        // aka delta_1_2x1_bgr
        float3 inverseAperture = lerp(green, magenta, floor(FMOD(coord.x, 2.0)));
        weights                = lerp(apertureWeights, inverseAperture, floor(FMOD(coord.y, 2.0)));
        return weights;
    }
    else if (phosphorLayout == 3) {
        // slot mask for RGB panels; looks okay at 1080p, looks better at 4K
        // {magenta, green, black,   black},
        // {magenta, green, magenta, green},
        // {black,   black, magenta, green}

        // GLSL can't do 2D arrays until version 430, so do this stupid thing instead for compatibility's sake:
        // First lay out the horizontal pixels in arrays
        float3 slotMask1[4] = { magenta, green, black,   black };
        float3 slotMask2[4] = { magenta, green, magenta, green };
        float3 slotMask3[4] = { black,   black, magenta, green };

        w = int(floor(FMOD(coord.y, 3.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        // do a big, dumb comparison in place of a 2D array
        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] :  slotMask3[z];
        return weights;
    }
    else if (phosphorLayout == 4) {
        // classic aperture for RBG panels; good for 1080p, too small for 4K+
        weights = lerp(yellow, blue, floor(FMOD(coord.x, 2.0)));
        return weights;
    }
    else if (phosphorLayout == 5) {
        // 2x2 shadow mask for RBG panels; good for 1080p, too small for 4K+
        float3 inverseAperture = lerp(blue, yellow, floor(FMOD(coord.x, 2.0)));

        weights = lerp(
            lerp(yellow, blue, floor(FMOD(coord.x, 2.0))),
            inverseAperture,
            floor(FMOD(coord.y, 2.0))
        );

        return weights;
    }
    else if (phosphorLayout == 6) {
        // aperture_1_4_rgb; good for simulating lower
        float3 ap[4] = { red, green, blue, black };

        z = int(floor(FMOD(coord.x, 4.0)));

        weights = ap[z];
        return weights;
    }
    else if (phosphorLayout == 7) {
        // aperture_2_5_bgr
        float3 ap[5] = { red, magenta, blue, green, green };

        z = int(floor(FMOD(coord.x, 5.0)));

        weights = ap[z];
        return weights;
    }
    else if (phosphorLayout == 8) {
        // aperture_3_6_rgb
        float3 ap[7] = { red, red, yellow, green, cyan, blue, blue };

        z = int(floor(FMOD(coord.x, 7.0)));

        weights = ap[z];
        return weights;
    }
    else if (phosphorLayout == 9) {
        // reduced TVL aperture for RGB panels
        // aperture_2_4_rgb
        float3 ap[4] = { red, yellow, cyan, blue };

        z = int(floor(FMOD(coord.x, 4.0)));

        weights = ap[z];
        return weights;
    }
    else if (phosphorLayout == 10) {
        // reduced TVL aperture for RBG panels
        float3 ap[4] = { red, magenta, cyan, green };

        z = int(floor(FMOD(coord.x, 4.0)));

        weights = ap[z];
        return weights;
    }
    else if(phosphorLayout == 11) {
        // delta_1_4x1_rgb; dunno why this is called 4x1 when it's obviously 4x2 /shrug
        float3 slotMask1[4] = { red, green, blue, black };
        float3 slotMask2[4] = { blue, black, red, green };

        w = int(floor(FMOD(coord.y, 2.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? slotMask1[z] : slotMask2[z];
        return weights;
    }
    else if (phosphorLayout == 12) {
        // delta_2_4x1_rgb
        float3 slotMask1[4] = { red, yellow, cyan, blue };
        float3 slotMask2[4] = { cyan, blue, red, yellow };

        w = int(floor(FMOD(coord.y, 2.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? slotMask1[z] : slotMask2[z];
        return weights;
    }
    else if (phosphorLayout == 13) {
        // delta_2_4x2_rgb
        float3 slotMask1[4] = { red, yellow, cyan, blue };
        float3 slotMask2[4] = { red, yellow, cyan, blue };
        float3 slotMask3[4] = { cyan, blue, red, yellow };
        float3 slotMask4[4] = { cyan, blue, red, yellow };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : (w == 3) ? slotMask3[z] : slotMask4[z];
        return weights;
    }
    else if (phosphorLayout == 14) {
        // slot mask for RGB panels; too low-pitch for 1080p, looks okay at 4K, but wants 8K+
        // {magenta, green, black, black,   black, black},
        // {magenta, green, black, magenta, green, black},
        // {black,   black, black, magenta, green, black}
        float3 slotMask1[6] = { magenta, green, black, black,   black, black };
        float3 slotMask2[6] = { magenta, green, black, magenta, green, black };
        float3 slotMask3[6] = { black,   black, black, magenta, green, black };

        w = int(floor(FMOD(coord.y, 3.0)));
        z = int(floor(FMOD(coord.x, 6.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : slotMask3[z];
        return weights;
    }
    else if(phosphorLayout == 15) {
        // slot_2_4x4_rgb
        // {red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue },
        // {red,   yellow, cyan,  blue,  black, black,  black, black},
        // {red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue },
        // {black, black,  black, black, red,   yellow, cyan,  blue }
        float3 slotMask1[8] = { red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue  };
        float3 slotMask2[8] = { red,   yellow, cyan,  blue,  black, black,  black, black };
        float3 slotMask3[8] = { red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue  };
        float3 slotMask4[8] = { black, black,  black, black, red,   yellow, cyan,  blue  };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 8.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : (w == 3) ? slotMask3[z] : slotMask4[z];
        return weights;
    }
    else if(phosphorLayout == 16) {
        // slot mask for RBG panels; too low-pitch for 1080p, looks okay at 4K, but wants 8K+
        // {yellow, blue,  black,  black},
        // {yellow, blue,  yellow, blue},
        // {black,  black, yellow, blue}
        float3 slotMask1[4] = { yellow, blue,  black,  black };
        float3 slotMask2[4] = { yellow, blue,  yellow, blue  };
        float3 slotMask3[4] = { black,  black, yellow, blue  };

        w = int(floor(FMOD(coord.y, 3.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : slotMask3[z];
        return weights;
    }
    else if (phosphorLayout == 17) {
        // slot_2_5x4_bgr
        // {red,   magenta, blue,  green, green, red,   magenta, blue,  green, green},
        // {black, blue,    blue,  green, green, red,   red,     black, black, black},
        // {red,   magenta, blue,  green, green, red,   magenta, blue,  green, green},
        // {red,   red,     black, black, black, black, blue,    blue,  green, green}
        float3 slotMask1[10] = { red,   magenta, blue,  green, green, red,   magenta, blue,  green, green };
        float3 slotMask2[10] = { black, blue,    blue,  green, green, red,   red,     black, black, black };
        float3 slotMask3[10] = { red,   magenta, blue,  green, green, red,   magenta, blue,  green, green };
        float3 slotMask4[10] = { red,   red,     black, black, black, black, blue,    blue,  green, green };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 10.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : (w == 3) ? slotMask3[z] : slotMask4[z];
        return weights;
    }
    else if (phosphorLayout == 18) {
        // same as above but for RBG panels
        // {red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue },
        // {black, green,  green, blue,  blue,  red,   red,    black, black, black},
        // {red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue },
        // {red,   red,    black, black, black, black, green,  green, blue,  blue }
        float3 slotMask1[10] = { red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue  };
        float3 slotMask2[10] = { black, green,  green, blue,  blue,  red,   red,    black, black, black };
        float3 slotMask3[10] = { red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue  };
        float3 slotMask4[10] = { red,   red,    black, black, black, black, green,  green, blue,  blue  };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 10.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : (w == 3) ? slotMask3[z] : slotMask4[z];
        return weights;
    }
    else if(phosphorLayout == 19) {
        // slot_3_7x6_rgb
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  black, black, black,  black,  black, black, black},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {black, black, black,  black, black, black, black, black, red,   red,    yellow, green, cyan,  blue}

        float3 slotMask1[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slotMask2[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slotMask3[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  black, black, black,  black,  black, black, black };
        float3 slotMask4[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slotMask5[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slotMask6[14] = { black, black, black,  black, black, black, black, black, red,   red,    yellow, green, cyan,  blue  };

        w = int(floor(FMOD(coord.y, 6.0)));
        z = int(floor(FMOD(coord.x, 14.0)));

        weights = (w == 1) ? slotMask1[z] : (w == 2) ? slotMask2[z] : (w == 3) ? slotMask3[z] : (w == 4) ? slotMask4[z] : (w == 5) ? slotMask5[z] : slotMask6[z];
        return weights;
    }
    else {
        return weights;
    }
}

#endif // _MASK_WEIGHTS_FXH