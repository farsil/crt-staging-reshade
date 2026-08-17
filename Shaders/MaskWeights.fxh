#pragma once

#include "ReShade.fxh"

#define FMOD(a, b) (a - b * trunc(a / b))

/*
    A collection of CRT mask effects that work with LCD subpixel structures for
    small details

    author: hunterk
    license: public domain

    How to use it:

    Multiply your image by the float3 output:
    FragColor.rgb *= mask_weights(gl_FragCoord.xy, 1.0, 1);

    The function needs to be tiled across the screen using the physical pixels, e.g.
    gl_FragCoord (the "float2 coord" input). In the case of slang shaders, we use
    (vTexCoord.st * OutputSize.xy).

    The "mask_intensity" (float value between 0.0 and 1.0) is how strong the mask
    effect should be. Full-strength red, green and blue subpixels on a white pixel
    are the ideal, and are achieved with an intensity of 1.0, though this darkens
    the image significantly and may not always be desirable.

    The "phosphor_layout" (int value between 0 and 19) determines which phophor
    layout to apply. 0 is no mask/passthru.

    Many of these mask arrays are adapted from cgwg's crt-geom-deluxe LUTs, and
    those have their filenames included for easy identification

    NOTE: Having too many branches result in a black screen (but no
    compilation errors) on some older GPUs such as the Intel HD 4000 iGPU. So
    we're commenting out the branches that are not used by the adaptive CRT
    shaders.
*/
float3 MaskWeights(float2 coord, float mask_intensity, int phosphor_layout)
{
    float3 weights = 1.0;

    float on = 1.0;
    float off = 1.0 - mask_intensity;

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
    float3 aperture_weights = lerp(magenta, green, floor(FMOD(coord.x, 2.0)));

    if (phosphor_layout == 0) {
        return weights;
    }
    else if (phosphor_layout == 1) {
        // classic aperture for RGB panels; good for 1080p, too small for 4K+
        // aka aperture_1_2_bgr
        weights  = aperture_weights;
        return weights;
    }
    else if (phosphor_layout == 2) {
        // 2x2 shadow mask for RGB panels; good for 1080p, too small for 4K+
        // aka delta_1_2x1_bgr
        float3 inverse_aperture = lerp(green, magenta, floor(FMOD(coord.x, 2.0)));
        weights                 = lerp(aperture_weights, inverse_aperture, floor(FMOD(coord.y, 2.0)));
        return weights;
    }
    else if (phosphor_layout == 3) {
        // slot mask for RGB panels; looks okay at 1080p, looks better at 4K
        // {magenta, green, black,   black},
        // {magenta, green, magenta, green},
        // {black,   black, magenta, green}

        // GLSL can't do 2D arrays until version 430, so do this stupid thing instead for compatibility's sake:
        // First lay out the horizontal pixels in arrays
        float3 slotmask_x1[4] = { magenta, green, black,   black };
        float3 slotmask_x2[4] = { magenta, green, magenta, green };
        float3 slotmask_x3[4] = { black,   black, magenta, green };

        // find the vertical index
        w = int(floor(FMOD(coord.y, 3.0)));

        // find the horizontal index
        z = int(floor(FMOD(coord.x, 4.0)));

        // do a big, dumb comparison in place of a 2D array
        weights = (w == 1) ? slotmask_x1[z] : (w == 2) ? slotmask_x2[z] :  slotmask_x3[z];
        return weights;
    }
    else if (phosphor_layout == 4) {
        // classic aperture for RBG panels; good for 1080p, too small for 4K+
        weights  = lerp(yellow, blue, floor(FMOD(coord.x, 2.0)));
        return weights;
    }
    else if (phosphor_layout == 5) {
        // 2x2 shadow mask for RBG panels; good for 1080p, too small for 4K+
        float3 inverse_aperture = lerp(blue, yellow, floor(FMOD(coord.x, 2.0)));

        weights = lerp(
            lerp(yellow, blue, floor(FMOD(coord.x, 2.0))),
            inverse_aperture,
            floor(FMOD(coord.y, 2.0))
        );
        return weights;
    }
    else if (phosphor_layout == 6) {
        // aperture_1_4_rgb; good for simulating lower
        float3 ap4[4] = { red, green, blue, black };

        z = int(floor(FMOD(coord.x, 4.0)));

        weights = ap4[z];
        return weights;
    }
    else if (phosphor_layout == 7) {
        // aperture_2_5_bgr
        float3 ap3[5] = { red, magenta, blue, green, green };

        z = int(floor(FMOD(coord.x, 5.0)));

        weights = ap3[z];
        return weights;
	}
    else if (phosphor_layout == 8) {
        // aperture_3_6_rgb
        float3 big_ap[7] = { red, red, yellow, green, cyan, blue, blue };

        w = int(floor(FMOD(coord.x, 7.)));

        weights = big_ap[w];
        return weights;
    }
    else if (phosphor_layout == 9) {
        // reduced TVL aperture for RGB panels
        // aperture_2_4_rgb
        float3 big_ap_rgb[4] = { red, yellow, cyan, blue };

        w = int(floor(FMOD(coord.x, 4.)));

        weights = big_ap_rgb[w];
        return weights;
    }
    else if (phosphor_layout == 10) {
        // reduced TVL aperture for RBG panels
        float3 big_ap_rbg[4] = { red, magenta, cyan, green };

        w = int(floor(FMOD(coord.x, 4.)));

        weights = big_ap_rbg[w];
        return weights;
    }
    else if(phosphor_layout == 11) {
        // delta_1_4x1_rgb; dunno why this is called 4x1 when it's obviously 4x2 /shrug
        float3 delta_1_1[4] = { red, green, blue, black };
        float3 delta_1_2[4] = { blue, black, red, green };

        w = int(floor(FMOD(coord.y, 2.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? delta_1_1[z] : delta_1_2[z];
        return weights;
    }
    else if (phosphor_layout == 12) {
        // delta_2_4x1_rgb
        float3 delta_2_1[4] = { red, yellow, cyan, blue };
        float3 delta_2_2[4] = { cyan, blue, red, yellow };

        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? delta_2_1[z] : delta_2_2[z];
        return weights;
    }
    else if (phosphor_layout == 13) {
        // delta_2_4x2_rgb
        float3 delta_1[4] = { red, yellow, cyan, blue };
        float3 delta_2[4] = { red, yellow, cyan, blue };
        float3 delta_3[4] = { cyan, blue, red, yellow };
        float3 delta_4[4] = { cyan, blue, red, yellow };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? delta_1[z] : (w == 2) ? delta_2[z] : (w == 3) ? delta_3[z] : delta_4[z];
        return weights;
    }
    else if (phosphor_layout == 14) {
        // slot mask for RGB panels; too low-pitch for 1080p, looks okay at 4K, but wants 8K+
        // {magenta, green, black, black,   black, black},
        // {magenta, green, black, magenta, green, black},
        // {black,   black, black, magenta, green, black}
        float3 slot2_1[6] = { magenta, green, black, black,   black, black };
        float3 slot2_2[6] = { magenta, green, black, magenta, green, black };
        float3 slot2_3[6] = { black,   black, black, magenta, green, black };

        w = int(floor(FMOD(coord.y, 3.0)));
        z = int(floor(FMOD(coord.x, 6.0)));

        weights = (w == 1) ? slot2_1[z] : (w == 2) ? slot2_2[z] : slot2_3[z];
        return weights;
    }
    else if(phosphor_layout == 15) {
        // slot_2_4x4_rgb
        // {red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue },
        // {red,   yellow, cyan,  blue,  black, black,  black, black},
        // {red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue },
        // {black, black,  black, black, red,   yellow, cyan,  blue }
        float3 slotmask_RBG_x1[8] = { red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue  };
        float3 slotmask_RBG_x2[8] = { red,   yellow, cyan,  blue,  black, black,  black, black };
        float3 slotmask_RBG_x3[8] = { red,   yellow, cyan,  blue,  red,   yellow, cyan,  blue  };
        float3 slotmask_RBG_x4[8] = { black, black,  black, black, red,   yellow, cyan,  blue  };

        // find the vertical index
        w = int(floor(FMOD(coord.y, 4.0)));

        // find the horizontal index
        z = int(floor(FMOD(coord.x, 8.0)));

        weights = (w == 1) ? slotmask_RBG_x1[z] : (w == 2) ? slotmask_RBG_x2[z] : (w == 3) ? slotmask_RBG_x3[z] : slotmask_RBG_x4[z];
        return weights;
    }
    else if(phosphor_layout == 16) {
        // slot mask for RBG panels; too low-pitch for 1080p, looks okay at 4K, but wants 8K+
        // {yellow, blue,  black,  black},
        // {yellow, blue,  yellow, blue},
        // {black,  black, yellow, blue}
        float3 slot2_1[4] = { yellow, blue,  black,  black };
        float3 slot2_2[4] = { yellow, blue,  yellow, blue  };
        float3 slot2_3[4] = { black,  black, yellow, blue  };

        w = int(floor(FMOD(coord.y, 3.0)));
        z = int(floor(FMOD(coord.x, 4.0)));

        weights = (w == 1) ? slot2_1[z] : (w == 2) ? slot2_2[z] : slot2_3[z];
        return weights;
    }
    else if (phosphor_layout == 17) {
        // slot_2_5x4_bgr
        // {red,   magenta, blue,  green, green, red,   magenta, blue,  green, green},
        // {black, blue,    blue,  green, green, red,   red,     black, black, black},
        // {red,   magenta, blue,  green, green, red,   magenta, blue,  green, green},
        // {red,   red,     black, black, black, black, blue,    blue,  green, green}
        float3 slot_1[10] = { red,   magenta, blue,  green, green, red,   magenta, blue,  green, green };
        float3 slot_2[10] = { black, blue,    blue,  green, green, red,   red,     black, black, black };
        float3 slot_3[10] = { red,   magenta, blue,  green, green, red,   magenta, blue,  green, green };
        float3 slot_4[10] = { red,   red,     black, black, black, black, blue,    blue,  green, green };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 10.0)));

        weights = (w == 1) ? slot_1[z] : (w == 2) ? slot_2[z] : (w == 3) ? slot_3[z] : slot_4[z];
        return weights;
    }
    else if (phosphor_layout == 18) {
        // same as above but for RBG panels
        // {red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue },
        // {black, green,  green, blue,  blue,  red,   red,    black, black, black},
        // {red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue },
        // {red,   red,    black, black, black, black, green,  green, blue,  blue }
        float3 slot_1[10] = { red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue  };
        float3 slot_2[10] = { black, green,  green, blue,  blue,  red,   red,    black, black, black };
        float3 slot_3[10] = { red,   yellow, green, blue,  blue,  red,   yellow, green, blue,  blue  };
        float3 slot_4[10] = { red,   red,    black, black, black, black, green,  green, blue,  blue  };

        w = int(floor(FMOD(coord.y, 4.0)));
        z = int(floor(FMOD(coord.x, 10.0)));

        weights = (w == 1) ? slot_1[z] : (w == 2) ? slot_2[z] : (w == 3) ? slot_3[z] : slot_4[z];
        return weights;
    }
    else if(phosphor_layout == 19) {
        // slot_3_7x6_rgb
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  black, black, black,  black,  black, black, black},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue},
        // {black, black, black,  black, black, black, black, black, red,   red,    yellow, green, cyan,  blue}

        float3 slot_1[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slot_2[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slot_3[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  black, black, black,  black,  black, black, black };
        float3 slot_4[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slot_5[14] = { red,   red,   yellow, green, cyan,  blue,  blue,  red,   red,   yellow, green,  cyan,  blue,  blue  };
        float3 slot_6[14] = { black, black, black,  black, black, black, black, black, red,   red,    yellow, green, cyan,  blue  };

        w = int(floor(FMOD(coord.y, 6.0)));
        z = int(floor(FMOD(coord.x, 14.0)));

        weights = (w == 1) ? slot_1[z] : (w == 2) ? slot_2[z] : (w == 3) ? slot_3[z] : (w == 4) ? slot_4[z] : (w == 5) ? slot_5[z] : slot_6[z];
        return weights;
    }
    else {
        return weights;
    }
}