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
    vec3 distortion = vec3(
        perlin3d(position * uDistortionFrequencyWave + vec3(1.0, 0.0, 0.0)) - 0.5 ,
        -perlin3d(position * uDistortionFrequencyWave + vec3(0.0, 1.0, 0.0)) * 0.3 + 0.5 ,
        -perlin3d(position * uDistortionFrequencyWave + vec3(0.0, 0.0, 1.0))  -1.0
    ) * uDistortionStrengthWave;

    // Final displaced position with wave and distortion
    return position + waveDisplacement + distortion;
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


    if(progress < 0.25){
        mixedPosition = applyWaveFunction(mixedPosition);
    }

    // displace the position
    vec4 displacedPosition = getDisplacedPosition(mixedPosition) * 0.01;

    if(progress > 0.25){
        displacedPosition.y -= progress * 0.01;
    }
    
    // Final position
    vec4 modelPosition = modelMatrix * vec4(displacedPosition.xyz, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Point size
    gl_PointSize = aSize * uSize * uResolution.y * 3.0 + 0.2;
    gl_PointSize *= (1.0 / -viewPosition.z);

    //varyings
    vColor = mix(uColorA, uColorB, noise);
}