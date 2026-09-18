#version 120

// The final program is a full-screen post-processing pass supplied by Iris.
// gl_MultiTexCoord0 contains the 0..1 UV coordinates for the full-screen quad.
varying vec2 barrelTexCoord;

void main() {
    gl_Position = ftransform();
    barrelTexCoord = gl_MultiTexCoord0.st;
}
