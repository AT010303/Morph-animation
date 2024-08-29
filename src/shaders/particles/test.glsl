// #define M_PI 3.1415926535897932384626433832795
// #define M_PHI M_PI * (3.0 - sqrt(5.0)) // golden angle in radians
// #define SPHERE_OFFSET_Y 7.9
// #define SPHERE_SCALE 2.0
// #define SPHERE_GAP 0.03
// #define MOUSE_DISTANCE 0.4

// precision highp float;

// attribute float alpha;

// uniform float animation; // Wave -> sphere animation progress, in range [0, 1]
// uniform float revealAnimation; // Reveal animation progress, in range [0, 1]
// uniform float size;
// uniform float time;
// uniform float speed;
// uniform float sphereSpeed;
// uniform float sphereSize;
// uniform float sphereOffsetZ;
// uniform float sphereDotSize;
// uniform vec3 objectSize;
// uniform vec4[HIGHLIGHT_COUNT] highlights;
// uniform vec2 mouse; // in range [-1, 1]
// uniform vec2 mouseAnimated; // in range [-1, 1]
// uniform float screenRatio;

// uniform vec3 colorA;
// uniform vec3 colorB;
// uniform vec3 colorC;

// uniform vec3 colorSphereA;
// uniform vec3 colorSphereB;
// uniform vec3 colorSphereC;

// varying vec3 vColor;
// varying float vAlpha;

// // Depth test
// varying float vViewZDepth;

// // Highlight
// struct Highlight {
//     float size;
//     vec3 color;
// };

// // Noise
// float rand(vec2 n) {
//     return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
// }

// float noise(vec2 p) {
//     vec2 ip = floor(p);
//     vec2 u = fract(p);
//     u = u * u * (3.0 - 2.0 * u);

//     float res = mix(
//         mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),
//         mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x),
//         u.y
//     );
//     return res * res;
// }

// float wave(float x, float size) {
//     float position = mod(x, 1.0);
//     if (position > 0.0 && position < size) {
//         float progress = position / size;
//         return sin(smoothstep(0.0, 1.0, progress) * M_PI);
//     } else {
//         return 0.0;
//     }
// }

// // Generate waves
// float waves(vec3 position) {
//     float velocity = time * speed;
//     float velocityAnimated = (time + mouseAnimated.y * 10.0) * speed;
//     float x = position.x / objectSize.x; // in range [-0.5, 0.5]
//     float z = position.z / objectSize.z; // in range [-0.5, 0.5]

//     // Waves
//     float wave1 = wave(x + velocity * 0.02 + 0.0, 0.5) * wave(z - 0.25, 0.3) * 0.3;

//     float wave2 = wave(x + velocity * 0.02 + 0.0, 0.5) * wave(z - 0.25, 0.3) * 0.3;
//     wave2 += wave(x + velocity * 0.02 - 0.05, 0.2) * wave(z - 0.25, 0.3) * 0.3;

//     float wave6 = wave(x + velocity * 0.01 + 0.3, 0.5) * wave(z - 0.1, 0.3) * 0.3;
//     float wave7 = wave(x + velocity * 0.03 - 0.3, 0.5) * wave(z - 0.15, 0.2) * 0.3;

//     // Large wave in the middle
//     float waveMidLarge = cos(clamp(z * 10.0 + sin(x * 10.0 * 0.5 + velocityAnimated * 0.07) * 3.0, -M_PI, M_PI)) * 0.5 + 0.5;
//     waveMidLarge = pow(abs(waveMidLarge), 4.0) * sin(x * 10.0 * 0.5 + velocity * 0.1) * 0.7;

//     float waveMidMedium = cos(clamp(z * 25.0 + sin(x * 25.0 * 0.5 + velocity * 0.1) * 3.0, -M_PI, M_PI)) * 0.5 + 0.5;
//     waveMidMedium = pow(abs(waveMidMedium), 4.0) * sin(x * 10.0 * 0.5 + velocityAnimated * 0.1) * 0.3;

//     // Large soft wave at the back
//     float waveBackLargeSoft1 = wave(x + velocity * 0.01 + 0.4, 0.5) * wave(z - 0.3, 1.0) * 0.6;
//     float waveBackLargeSoft2 = wave(x + velocity * 0.012 + 0.6, 0.5) * wave(z - 0.23, 1.0) * 0.6;

//     // Small soft waves
//     float waveSmallSoft1 = (sin(x * 100.0 + velocity * 0.3) + cos(x * 80.0 + velocity * 0.4) + sin(x * 60.0 + velocity * 0.5)) * 0.05;
//     waveSmallSoft1 *= wave(z + 0.8, 0.2);

//     float waveSmallSoft2 = (sin(x * 95.0 + velocity * 0.5) + cos(x * 75.0 + velocity * 0.4) + sin(x * 55.0 + velocity * 0.3)) * 0.075;
//     waveSmallSoft2 *= wave(z + 0.65, 0.2);

//     float waveSmallSoft3 = (sin(x * 70.0 + velocityAnimated * 0.45) + cos(x * 50.0 + velocity * 0.35) + sin(x * 30.0 + velocityAnimated * 0.45)) * 0.1;
//     waveSmallSoft3 *= wave(z + 0.95, 0.2);

//     float waveSmallSoft4 = (sin(x * 60.0 + velocity * 0.35) + cos(x * 40.0 + velocityAnimated * 0.55) + sin(x * 20.0 + velocity * 0.5)) * 0.075;
//     waveSmallSoft4 *= wave(z + 1.1, 0.2);

//     float waveZ = sin(z * 20.0 + velocity * -0.2) * 0.1;

//     // Left side lower, right side higher
//     float slope = x * -2.0;

//     // Wave height
//     float waveHeight = objectSize.y;

//     return (wave1 + wave2 + wave6 + wave7 + waveMidLarge + waveMidMedium + waveBackLargeSoft1 + waveBackLargeSoft2 + waveSmallSoft1 + waveSmallSoft2 + waveSmallSoft3 + waveSmallSoft4 + waveZ + slope) 
//            * (1.0 - smoothstep(0.4, 0.55, z)) * waveHeight;
// }

// vec3 sphereAnimation(vec3 position) {
//     float velocity = time * sphereSpeed;
//     vec3 vPosition = normalize(position);

//     vec3 largeWave = vec3(
//         cos(vPosition.y * 10.0 + velocity * 0.5),
//         cos(vPosition.x * 13.33 + velocity * 0.5),
//         sin(vPosition.z * 16.66 + velocity * 0.5)
//     );

//     vec3 smallWave = vec3(
//         cos(vPosition.y * 3.0 + velocity * 0.75),
//         cos(vPosition.x * 5.3 + velocity * 0.75),
//         sin(vPosition.z * 4.1 + velocity * 0.75)
//     );

//     vec3 smallWave2 = vPosition * cos(vPosition.y * 33.0 + velocity * 0.75);

//     return largeWave * 0.02 + smallWave * 0.01 + smallWave2 * 0.01;
// }

// // Calculate offset so that there is a gap between items
// vec3 sphereGap(vec3 vPosition) {
//     float x = vPosition.x;
//     float y = vPosition.y;
//     vec3 gap = vec3(0.0, 0.0, 0.0);

//     if (y > 0.0) {
//         if (x < 0.0) {
//             if (x * -0.5 > y) {
//                 // Left
//                 gap.x = -SPHERE_GAP * 0.5;
//             } else {
//                 // Top
//                 gap.y = SPHERE_GAP;
//             }
//         } else {
//             if (x * 0.5 > y) {
//                 // Right
//                 gap.x = SPHERE_GAP * 0.5;
//             } else {
//                 // Top
//                 gap.y = SPHERE_GAP;
//             }
//         }
//     } else {
//         // Bottom
//         gap.y = -SPHERE_GAP;
//     }

//     return gap;
// }

// void main() {
//     vec3 position = vec3(position.x, position.y, position.z);
//     vec3 positionOffset = vec3(0.0, waves(position), 0.0);

//     position += positionOffset * revealAnimation;

//     // Sphere animation
//     vec3 spherePos = vec3(
//         sin(gl_InstanceID * M_PHI) * sqrt(float(gl_InstanceID)) * SPHERE_SCALE,
//         float(gl_InstanceID) * SPHERE_OFFSET_Y,
//         cos(gl_InstanceID * M_PHI) * sqrt(float(gl_InstanceID)) * SPHERE_SCALE
//     );

//     vec3 sphereAni = sphereAnimation(position);
//     vec3 gapOffset = sphereGap(spherePos);

//     spherePos += sphereAni + gapOffset;

//     vec3 sphereColor = mix(
//         mix(colorSphereA, colorSphereB, fract(float(gl_InstanceID) * 0.1)),
//         colorSphereC,
//         fract(float(gl_InstanceID) * 0.2)
//     );

//     vec3 finalColor = mix(
//         mix(colorA, colorB, abs(positionOffset.y)),
//         colorC,
//         revealAnimation
//     );

//     vColor = mix(finalColor, sphereColor, animation);
//     vAlpha = alpha;

//     gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

//     // Update the view depth for depth testing
//     vViewZDepth = gl_Position.z / gl_Position.w;
//     gl_PointSize = size * sphereDotSize * (1.0 + sin(float(gl_InstanceID) * M_PHI));
// }
















#define PI 3.14159265359

    uniform float u_time;
    uniform float u_pointsize;
    uniform float u_noise_amp_1;
    uniform float u_noise_freq_1;
    uniform float u_spd_modifier_1;
    uniform float u_noise_amp_2;
    uniform float u_noise_freq_2;
    uniform float u_spd_modifier_2;

    // 2D Random
    float random (in vec2 st) {
        return fract(sin(dot(st.xy,
                            vec2(12.9898,78.233)))
                    * 43758.5453123);
    }

    // 2D Noise based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise (in vec2 st) {
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

    void main() {
      gl_PointSize = u_pointsize;

      vec3 pos = position;
      // pos.xy is the original 2D dimension of the plane coordinates
      pos.z += noise(pos.xy * u_noise_freq_1 + u_time * u_spd_modifier_1) * u_noise_amp_1;
      // add noise layering
      // minus u_time makes the second layer of wave goes the other direction
      pos.z += noise(rotate2d(PI / 4.) * pos.yx * u_noise_freq_2 - u_time * u_spd_modifier_2 * 0.6) * u_noise_amp_2;

      vec4 mvm = modelViewMatrix * vec4(pos, 1.0);
      gl_Position = projectionMatrix * mvm;
    }
    `