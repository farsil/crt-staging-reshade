#ifndef _MACROS_FXH
#define _MACROS_FXH

#define FMOD(a, b) (a - b * trunc(a / b))

#define GAMMA_IN(color) pow((color), float3(InputGamma, InputGamma, InputGamma))

#define GAMMA_OUT(color) pow((color), float3(1.0 / OutputGamma, 1.0 / OutputGamma, 1.0 / OutputGamma))

#endif // _MACROS_FXH