# Barrel Shader for Iris

Minimal Iris-compatible shader pack that applies only an aspect-correct radial
barrel-distortion post-process.  It is intended as a subtle visual aid when
playing Minecraft Java Edition 1.21.1 at a wide field of view (for example,
110 degrees).  It does **not** change the game's projection matrix or FOV.

## Pack layout

```text
BarrelShader/
├── shaders/
│   ├── final.vsh
│   └── final.fsh
├── shaders.properties
└── README.md
```

`final.vsh` and `final.fsh` are the conventional Iris/OptiFine shader-pack
final-pass filenames.  Iris supplies the full-screen geometry, `colortex0`
scene-colour texture, `viewWidth`, and `viewHeight`; no Minecraft mod code or
additional render pass is used.

## Installation (Minecraft 1.21.1 / NeoForge 21.1.249)

1. Install a build of **Iris Shaders for Minecraft 1.21.1** that is compatible
   with the NeoForge instance.  Iris must be present as the shader loader; this
   repository is a shader pack, not a NeoForge mod.
2. Put this directory, or a ZIP whose root contains `shaders/` and
   `shaders.properties`, in the instance's `shaderpacks` directory.  Do not put
   an extra parent directory inside the ZIP.
3. Start Minecraft, open **Video Settings → Shader Packs**, select **Barrel
   Shader**, and apply it.
4. Set Minecraft's **Field of View** to **110°** (or the desired wide FOV) in
   the normal video/accessibility settings.  Reload the selected shader pack
   after editing files manually.

## Settings

Open **Shader Pack Settings** in Iris to edit these two values:

| Setting | Default | Meaning |
| --- | ---: | --- |
| `BARREL_K1` | `0.012` | Primary radial strength. Increase for more curvature. |
| `BARREL_K2` | `0.000` | Optional higher-order edge adjustment. Keep at zero initially. |

For a gentler result choose `BARREL_K1 = 0.004` or `0.008`.  For a stronger
wide-angle look choose `0.016` or `0.020`; use `BARREL_K2 = 0.001` only when
the outermost region needs a little more curvature.  Larger positive values
produce more black crop at the screen boundary by design.  The values can also
be changed directly at the two `#define` lines in `shaders/final.fsh`.

## Math and edge behaviour

For every output UV, the final pass evaluates:

```glsl
p = uv * 2.0 - 1.0;
p.x *= aspect;
r2 = dot(p, p);
p *= 1.0 + k1 * r2 + k2 * r2 * r2;
p.x /= aspect;
sourceUv = p * 0.5 + 0.5;
```

Multiplying only the centered X coordinate by `viewWidth / viewHeight` before
computing `r2` makes equal radii remain equal on non-square displays.  Thus the
effect is radial rather than elliptical at 16:9, ultrawide, and other aspect
ratios.  The centre has `r2 = 0`, so it remains unchanged; the scale changes
smoothly as the distance from the centre increases.

The pass samples the already rendered `colortex0` scene at the transformed UV.
Positive coefficients move those samples outward, curving the displayed image
and reducing the perceived edge stretching of a very wide rectilinear view.
Coordinates outside `[0, 1]` are explicitly output as opaque black, avoiding
undefined/clamped texture reads and resolution-dependent wrap artefacts.

This is a lightweight single texture fetch for valid pixels plus a few scalar
operations.  It cannot fully reconstruct a physically correct fisheye or other
camera projection: Minecraft has already rendered a perspective-projected scene
before this post-process runs.  The FOV-110 defaults are therefore a visual
starting point, not a mathematical conversion from 110° to a distortion
coefficient.

## Compatibility notes

The shaders use GLSL `#version 120`, `ftransform`, `gl_MultiTexCoord0`,
`varying`, `gl_FragColor`, and `texture2D`: the legacy OpenGL GLSL interface
used by Iris-compatible OptiFine-format shader-pack final passes.  The pack
uses no OptiFine-only rendering functions, no compute features, and no optional
effects such as bloom, vignette, colour grading, chromatic aberration, or
motion blur.
