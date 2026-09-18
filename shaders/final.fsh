#version 120

/*
 * Barrel Shader -- Iris final pass
 *
 * These are Iris/OptiFine-style shader-pack options.  Iris discovers the
 * allowed values from the comments and exposes them in Shader Pack Settings.
 * The defaults are a subtle starting point intended for Minecraft's 110° FOV.
 * They do not change Minecraft's camera FOV.
 */
#define BARREL_K1 0.012 // [0.000 0.004 0.008 0.012 0.016 0.020 0.025]
#define BARREL_K2 0.000 // [0.000 0.001 0.002 0.004]

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 barrelTexCoord;

void main() {
    // Convert to centered coordinates, then make the radial metric circular.
    vec2 p = barrelTexCoord * 2.0 - 1.0;
    float aspect = viewWidth / max(viewHeight, 1.0);
    p.x *= aspect;

    float r2 = dot(p, p);
    float scale = 1.0 + BARREL_K1 * r2 + BARREL_K2 * r2 * r2;
    p *= scale;

    // Return from aspect-corrected centered space to an ordinary texture UV.
    p.x /= aspect;
    vec2 sourceUv = p * 0.5 + 0.5;

    // Sampling outside the rendered image is intentionally black rather than
    // relying on a driver-specific texture wrap mode. This gives a clean,
    // stable crop at the edges for positive barrel coefficients.
    if (sourceUv.x < 0.0 || sourceUv.x > 1.0 ||
        sourceUv.y < 0.0 || sourceUv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        gl_FragColor = texture2D(colortex0, sourceUv);
    }
}
