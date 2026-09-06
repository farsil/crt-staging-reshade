# DOSBox Staging CRT shaders for ReShade

A ReShade port of the collection of CRT shaders used in the
[DOSBox Staging](https://www.dosbox-staging.org/) project.

<img width="667" height="500" alt="np21w-popfulmail" src="https://github.com/user-attachments/assets/03ce7964-0ece-4d6b-a114-6a873e29fac4" />

*Popful Mail on Neko Project 21W, using VGA 4K preset
([click to enlarge](https://github.com/user-attachments/assets/03ce7964-0ece-4d6b-a114-6a873e29fac4))*

## The Shaders

This repository provides three different shaders (note that the 1080p shaders
are packaged together in the same file):

- CRT Hyllian
- CRT 1080p Single Scan
- CRT 1080p Double Scan

CRT Hyllian should be the shader of choice under most circumstances. However, if
you have a 1080p screen, you may get better results with the 1080p shaders,
depending on the source height and whether the source image requires double
scanning (as it was the case for most VGA games).

In general, you should use the 1080p shaders if the source height is more than
320 pixels (160 pixels) when the source image is single scanned (double
scanned).

## The Presets

This repository includes several preset templates that can be used as a quick
start to emulate various CRT monitors. You still need to set the source size
via the preprocessor directives. VGA presets are double scanned by default.

## Configuration settings

The three categories of configuration settings are resolution, image adjustments
and CRT emulation.

### Resolution

For the shader to work correctly, the application must display the image in the
center of the screen.

#### Original Size

Only visible if the preprocessor directive `ENABLE_DOWNSAMPLING` is set to 1.
Some applications are only capable to produce an upscaled image. If that's the
case, specify the upscaled size as it is produced by the application: the shader
will take care of downsampling to the source size.

#### Source Size

Resolution of the source image as if it was produced directly by the original
hardware. For example, the source size for the typical NES game is 256 x 240
pixels. Note that due to how the shaders are implemented, it must be set via the
preprocessor directives `SOURCE_WIDTH` and `SOURCE_HEIGHT`.

#### Upscaling Strategy

Specifies an upscaling strategy.

- Y Fill: the shader fills all available vertical space the application allows
          for. The viewport width is then calculated to maintain a 4:3 ratio.
          It may produce uneven pixels, especially on lower resolution screens.
- Y Integer (default): the shader finds the highest integer multiplier that
                       allows the image to fit vertically. The viewport width is
                       then calculated like Y Fill. Sacrifices some screen real
                       estate to make rows perfectly even, although this may
                       still result in uneven columns.
- XY Integer: the shader finds the highest integer multipliers for both
              width and height that best approximate the 4:3 ratio. This
              produces even rows and columns at the cost of a potentially
              incorrect aspect ratio.

#### Double scan

Emulates the VGA double scanning by effectively doubling the source resolution.

### Image adjustments

These settings emulate the controls of a CRT monitor.

#### Saturation

Set the saturation of the video output (0.0 by default). Valid range is -1.0 to
1.0. Applied directly to the raw RGB values of the framebuffer image, similarly
to digital contrast.

#### Digital Contrast

Set the digital contrast of the video output (0.0 by default). Valid range is
-2.0 to 2.0. Unlike contrast, this is applied directly to the raw RGB values of
the framebuffer image.

#### Color Temperature

Set the color temperature (white point) of the video output, in Kelvin (K).
Valid range is 3000 to 10000. 6500 K is the neutral point for most modern
displays. Values below 6500 produce warmer colors; above 6500 produce cooler
colors.

#### Color Temperature Luma Preserve

Preserve image luminosity prior to color temperature adjustment (0.0 by
default). Valid range is 0.0 to 1.0. 0 performs no luminosity preservation; 1.0
fully preserves it. Values greater than 0.0 result in inaccurate color
temperatures in brighter shades, so keep this at 0.0 or close to it if your
monitor is bright enough.

#### Black Level Boost

Raise the black level of the video output (0.0 by default). Valid range is 0.0
to 1.0. 0.0 does not raise the black level. Applied before brightness and
contrast.

#### Color Space

Set the color space of the video output. Wide gamut color spaces can
reproduce CRT phosphor colors that fall outside the sRGB gamut.

#### CRT Color profile

Set a CRT color profile for more authentic video output emulation.

Possible values:

- None (default): Display raw colors without any color profile transforms.
                  This will result in inaccurate colors and gamma on modern
                  displays.
- EBU: used in high-end professional CRT monitors such as the Sony BVM/PVM
       series.
- P22: most common in lower-end CRT monitors.
- SMPTE “C”: the standard for American broadcast video monitors.
- Philips: displays colors typical to 15 kHz home computer monitors (e.g.,
           the Commodore 1084S). Intended to be used with color_temperature set
           to 6500. Output looks yellowish due to the ~6100 K color temperature
           baked into the profile. Needs a DCI-P3 display for the most accurate
           results.
- Trinitron: typical Sony Trinitron CRT TV and monitor colors. Intended to be
             used with color_temperature set to 6500. Output looks blueish due
             to the ~9300 K color temperature baked into the profile.
             Needs a DCI-P3 display for the most accurate results.

#### Color Gain

Set gain factor of each color channel (1.0 by default). Valid range is 0.0 to
2.0. 1.0 means no change.

#### Brightness

Set the brightness of the video output (45 by default). Valid range is 0 to 100.
Emulates the brightness control of CRT monitors that sets the black point;
higher values raise the blacks.

#### Contrast

Set the contrast of the video output (65 by default). Valid range is 0 to 100.
Emulates the contrast control of CRT monitors that sets the white point;
higher values raise the blacks (lower brightness to compensate).

#### Gamma

Set the gamma of the video output (0.0 by default). Valid range is -1.0 to 1.0.
Additional gamma adjustment relative to the emulated monitor’s gamma.

### CRT emulation

This section provides controls that affect how the CRT monitor is emulated.

#### Spot Size

✗ Hyllian
✓ 1080p single scan
✗ 1080p double scan

Sets the electron beam spot size (0.85 wide, 0.80 tall by default). Valid range
is 0.0 to 1.0.

#### Beam Width

✓ Hyllian
✗ 1080p single scan
✗ 1080p double scan

Sets the electron beam width (1.00 min, 1.20 max by default). Valid range is 0.0
to 2.0.

#### Scanlines Strength

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Hyllian: Sets the scanlines strength. (0.70 by default). Valid range is 0.0 to
1.0.

1080p: Sets the minimum and maximum scanlines strength (0.80 min, 0.85 max by
default). Valid range is 0.0 to 1.0.

#### Color Boost

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Hyllian: Sets color boost multiplier (2.50 by default).  Valid range is 0.0 to
4.0. 1.0 means no change.

1080p: Sets color boost multiplier for even and odd rows of pixels (2.50 even,
2.50 odd by default). Valid range is 0.0 to 5.0. 1.0 means no change.

This boost is applied before phosphor mask emulation, while the Color Gain
setting is applied to the source image, before the CRT emulation shader.

#### Phosphor Layout

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Sets the emulated phosphor layout (0 by default). 0 means no shadow mask
emulation. In general, lower values look better at 1080p, while higher values
tend to be better at higher resolutions.

#### Mask Intensity

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Sets the intensity of the shadow mask (0.55 by default). Valid range is 0.0 to
1.0.

#### Input Gamma

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Sets the gamma level of the source image (2.4 by default) Valid range is 0.0
to 5.0.

#### Output Gamma

✓ Hyllian
✓ 1080p single scan
✓ 1080p double scan

Sets the gamma level of the output image (2.48 by default) Valid range is 0.0
to 5.0.

#### Anti Ringing

✓ Hyllian
✗ 1080p single scan
✗ 1080p double scan

Sets the anti-ringing filter strength (1.0 by default). Valid range is 0.0 to
1.0.

#### Horizontal Filter

✓ Hyllian
✗ 1080p single scan
✗ 1080p double scan

Chooses the horizontal filter to be used for cubic interpolation while
upscaling. (Hermite by default). Each filter produces different artifacts, but
in general Hermite and Catmull-Rom tend to produce the best results.

## Credits

Credits go to Guest(r), prod80 and Dogway for the image adjustment shader,
Hyllian for the shader with the same name, hunterk for the phosphor mask
emulation.

And of course the DOSBox Staging team for putting everything together into the
shaders I converted to the ReShade format and for writing the image adjustments
documentation and the presets.
