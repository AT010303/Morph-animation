precision highp float;

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
uniform vec3 uColorC;

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

vec4 getSphereDisplacedPosition(vec3 _position) {
    vec3 displacementPosition = _position;
    displacementPosition += perlin4d(vec4(displacementPosition * uDistortionFrequency, 10.0 * uTimeFrequency)) * uDistortionStrength;

    float perlinStrength = perlin4d(vec4(displacementPosition * uDisplacementFrequency, 10.0 * uTimeFrequency));

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

// Function to create a Z-axis rotation matrix
mat3 rotation3dZ(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat3(c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);
}

vec3 rotateZ(vec3 v, float angle) {
    return rotation3dZ(angle) * v;
}



void main() {
    // float progress = 0.5;

    float noiseOrigin = simplexNoise3d(position * 0.25);
    float noiseTarget = simplexNoise3d(aPositionTarget * 0.25);


    float noise = mix(noiseOrigin, noiseTarget, uProgress);
    noise = smoothstep(-1.0, 1.0, noise);

    noise = pow(noise, 2.0);
    
    noise = smoothstep(-1.0, 1.0, noise);

    float duration = 0.4;
    float delay = (1.0 - duration) * noise;
    float end = delay + duration;
    float progress = smoothstep(delay, end, uProgress);

    vec3 mixedPosition = mix(position, aPositionTarget, progress);

    if(progress <= 0.85) {
        mixedPosition = applyWaveFunction(mixedPosition);
    }
    float distortion = pnoise((mixedPosition + 100.0 * 0.1), vec3(10.0) * 2.0) * 1.0;
    // displace the position
    vec3 pos = mixedPosition + distortion * 0.25;

    vec4 displacedPosition = getDisplacedPosition(mixedPosition) * 0.01;

    displacedPosition.xyz += pos;

    if(progress >= 0.85) {
        displacedPosition = getSphereDisplacedPosition(mixedPosition) * 0.01;
        displacedPosition.xyz += pos.xyz * 1.1;
        float angle = mod(sin(mixedPosition.y * 0.5 + uTime * 0.2) * 10.0, 360.0);
        displacedPosition.xyz = rotateY(displacedPosition.xyz, angle * PI * 0.1);
    }

    if(progress < 0.85) {
        displacedPosition = getDisplacedPosition(mixedPosition) * 0.01;
        displacedPosition.x *= 150.0;
        displacedPosition.y *= 150.0;
        displacedPosition.z *= 150.0;
    }
    displacedPosition.y -= pow(progress * 1.2, 3.0);

    // Final position
    vec4 modelPosition = modelMatrix * vec4(displacedPosition.xyz, 1.0);

    // tilt the modelPosition around the z axis
    float tiltAngle = pow(progress, 10.0) + 0.05;

    modelPosition.xyz = rotateZ(modelPosition.xyz, tiltAngle);
    modelPosition.x -= (progress + 0.5);
    modelPosition.y -= (progress);

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
    if(progress > 0.75) {
        gl_PointSize = ((pow((aSize * distortion * size) + 0.6, 2.0)) * ((0.5 + uResolution.y) * 12.0));
    }
    gl_PointSize *= (0.9 / -viewPosition.z);

    //varyings

    // distortion = pow(distortion, 3.0);

    if(progress >= 0.85) {
        vColor = mix(uColorC, uColorA, pow(distortion, 2.0));
    } else {
        vColor = mix(uColorB, uColorA, pow(distortion, 2.0));
    }

}
