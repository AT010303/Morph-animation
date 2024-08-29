uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;
uniform float uTime;
uniform float uDistortionFrequency;
uniform float uDistortionStrength;
uniform float uDisplacementFrequency;
uniform float uDisplacementStrength;
uniform float uTimeFrequency;


uniform vec3 uColorA;
uniform vec3 uColorB;

attribute vec3 aPositionTarget;
attribute float aSize;

varying vec3 vColor;


#define PI 3.1415926535897932384626433832795

#include ../includes/simplexNoise3d.glsl
#include ../includes/perlin4d.glsl
#include ../includes/perlin3d.glsl


// Wave function similar to the one in the original code
float wave(float x, float size) {
    float position = mod(x, 1.0);
    if (position > 0.0 && position < size) {
        float progress = position / size;
        return sin(smoothstep(0.0, 1.0, progress) * PI);
    } else {
        return 0.0;
    }
}

// Function to generate wave effects similar to the provided GLSL code
float waves(vec3 position) {
    float velocity = uTime * 0.1; // Adjust speed
    float x = position.x / 10.0;  // Scale the x position as needed
    float z = position.z / 10.0;  // Scale the z position as needed
    
    // Customizable wave parameters
    float wave1 = wave(x + velocity * 0.02, 0.5) * wave(z - 0.25, 0.3) * 0.3;
    float wave2 = wave(x + velocity * 0.03, 0.4) * wave(z - 0.2, 0.3) * 0.3;

    // Combining multiple wave layers
    float combinedWaves = wave1 + wave2;

    // Scale the wave effect
    float waveHeight = 0.5; // Adjust wave height
    return combinedWaves * waveHeight;
}


vec4 getDisplacedPosition(vec3 _position) {
    vec3 displacementPosition = _position;
    displacementPosition += perlin4d(vec4(displacementPosition * uDistortionFrequency, uTime * uTimeFrequency)) * uDistortionStrength;

    float perlinStrength = perlin4d(vec4(displacementPosition * uDisplacementFrequency, uTime * uTimeFrequency));

    vec3 displacedPosition = _position;
    displacedPosition += normalize(_position) * perlinStrength * uDisplacementStrength;

    return vec4(displacedPosition, perlinStrength);
}


// 2D Random
    float random (in vec2 st) {
        return fract(sin(dot(st.xy,
                            vec2(12.9898,78.233)))
                    * 43758.5453123);
    }

    

float noise2 (in vec2 st) {
        vec2 i = floor(st);
        vec2 f = fract(st);

        // Four corners in 2D of a tile
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));

        // Smooth Interpolation

        // Cubic Hermine Curve.  Same as SmoothStep()
        vec2 u = f*f*(3.0-2.0*f);
        // u = smoothstep(0.,1.,f);

        // Mix 4 coorners percentages
        return mix(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
    }

    mat2 rotate2d(float angle){
        return mat2(cos(angle),-sin(angle),
                  sin(angle),cos(angle));
    }

void main()
{
    // float progress = 0.5;

    float noiseOrigin = simplexNoise3d(position * 0.2);
    float noiseTarget = simplexNoise3d(aPositionTarget * 0.2);
    float noise = mix(noiseOrigin, noiseTarget, uProgress);
    noise = smoothstep(-1.0, 1.0, noise);


    float duration = 0.4;
    float delay = (1.0 - duration) * noise;
    float end = delay + duration;
    float progress = smoothstep(delay, end, uProgress);

    vec3 mixedPosition = mix(position, aPositionTarget, progress);


    vec3 pos = position;

    float uNoiseFreq1 = 3.0;
    float uNoiseAmplitude1 = 0.2;
    float uSpeedModifier1 = 1.0;

    float uNoiseFreq2 = 2.0;
    float uNoiseAmplitude2 = 0.3;
    float uSpeedModifier2 = 0.8;

    pos.z += noise2(pos.xy * uNoiseFreq1 + uTime * uSpeedModifier1) * uNoiseAmplitude1;

    pos.z += noise2(rotate2d(PI / 4.0) * pos.xy * uNoiseFreq2 - uTime * uSpeedModifier2 * 0.6) * uNoiseAmplitude2;

    // mixedPosition += pos.x;
    // mixedPosition += pos.z;
    

    

    // Final position
    vec4 modelPosition = modelMatrix * vec4(mixedPosition, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Point size
    gl_PointSize = aSize * uSize * uResolution.y * 3.0;
    gl_PointSize *= (1.0 / - viewPosition.z);


    //varyings
    vColor = mix(uColorA, uColorB, noise);
}