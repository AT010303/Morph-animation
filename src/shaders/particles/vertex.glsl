uniform float uTime;
uniform float uDistortionFrequency;
uniform float uDistortionStrength;
uniform float uDisplacementFrequency;
uniform float uDisplacementStrength;
uniform float uTimeFrequency;

uniform float uDistortionFrequencyWave;
uniform float uDistortionStrengthWave;
uniform float uDisplacementFrequencyWave;
uniform float uDisplacementStrengthWave;

uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;

uniform vec3 uColorA;
uniform vec3 uColorB;

attribute vec3 aPositionTarget;
attribute float aSize;

varying vec3 vColor;

#define PI 3.1415926535897932384626433832795

#include ../includes/simplexNoise3d.glsl
#include ../includes/perlin4d.glsl
#include ../includes/perlin3d.glsl
#include ../includes/waves.glsl
#include ../includes/perodic.glsl

vec4 getDisplacedPosition(vec3 _position) {
    vec3 displacementPosition = _position;
    displacementPosition += perlin4d(vec4(displacementPosition * uDistortionFrequency, uTime * uTimeFrequency)) * uDistortionStrength;

    float perlinStrength = perlin4d(vec4(displacementPosition * uDisplacementFrequency, uTime * uTimeFrequency));

    vec3 displacedPosition = _position;
    displacedPosition += normalize(_position) * perlinStrength * uDisplacementStrength;

    return vec4(displacedPosition, perlinStrength);
}

vec3 applyWaveFunction(vec3 position) {
    // Generate Perlin noise based on position and time
    float perlinValue = perlin3d(vec3(position.xz * uDisplacementFrequencyWave, uTime * uTimeFrequency * 0.65));

    // Apply wave height and normalize the wave effect
    vec3 waveDisplacement = vec3(0.0, perlinValue * uDisplacementStrengthWave, 0.0);

    // Apply distortion if needed
    vec3 distortion = vec3(perlin3d(position * uDistortionFrequencyWave + vec3(1.0, 0.0, 0.0)) - 0.5, -perlin3d(position * uDistortionFrequencyWave + vec3(0.0, 1.0, 0.0)) * 0.3 + 0.5, -perlin3d(position * uDistortionFrequencyWave + vec3(0.0, 0.0, 1.0)) - 1.0) * uDistortionStrengthWave;

    // Final displaced position with wave and distortion
    return position + waveDisplacement + distortion;
}

mat3 rotation3dY(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat3(c, 0.0, -s, 0.0, 1.0, 0.0, s, 0.0, c);
}

vec3 rotateY(vec3 v, float angle) {
    return rotation3dY(angle) * v;
}

void main() {
    // float progress = 0.5;

    float noiseOrigin = simplexNoise3d(position * 0.2);
    float noiseTarget = simplexNoise3d(aPositionTarget * 0.2);
    float noise = mix(noiseOrigin, noiseTarget, uProgress);
    noise = smoothstep(-1.0, 1.0, noise);

    noise = pow(noise, 3.0);

    float duration = 0.4;
    float delay = (1.0 - duration) * noise;
    float end = delay + duration;
    float progress = smoothstep(delay, end, uProgress);

    vec3 mixedPosition = mix(position, aPositionTarget, progress);

    if(progress < 0.45) {
        mixedPosition = applyWaveFunction(mixedPosition);
    }
    float distortion = pnoise((mixedPosition + uTime * 0.1), vec3(10.0) * 2.0) * 1.0;
    // displace the position
    vec3 pos = mixedPosition + distortion * 0.25;

    vec4 displacedPosition = getDisplacedPosition(mixedPosition) * 0.01;

    displacedPosition.xyz += pos;

    if(progress >= 0.2) {
        displacedPosition.xyz += pos.xyz * 0.01;
        displacedPosition.xyz *= 1.0;

        float angle = sin(mixedPosition.y * 0.45 + 5.0 ) * 10.0;
        displacedPosition.xyz = rotateY(displacedPosition.xyz, angle * PI * 0.01);
    }

    if(progress < 0.25) {
        displacedPosition = getDisplacedPosition(mixedPosition) * 0.01;
        displacedPosition.x *= 150.0;
        displacedPosition.y *= 150.0;
        displacedPosition.z *= 150.0;

    }
    displacedPosition.y -= progress * 0.1;

    // Final position
    vec4 modelPosition = modelMatrix * vec4(displacedPosition.xyz, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Point size
    float size = uSize;
    if(progress > 0.5) {
        size -= progress * 0.4;
    } else {
        size = uSize * 1.5;
    }

    gl_PointSize = aSize * size * uResolution.y * 10.0;
    gl_PointSize *= (1.0 / -viewPosition.z);

    //varyings
    vColor = mix(uColorA, uColorB, noise);
}
