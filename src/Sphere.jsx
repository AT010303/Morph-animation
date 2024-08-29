import { useAspect, useGLTF, useScroll } from '@react-three/drei';
import { useFrame } from '@react-three/fiber';
// import { useFrame } from '@react-three/fiber';
// import gsap from 'gsap';
import { useControls } from 'leva';
import { useEffect, useMemo, useRef } from 'react';
import * as THREE from 'three';

import particlesFragmentShader from './shaders/particles/fragment.glsl';
import particlesVertexShader from './shaders/particles/vertex.glsl';

const Sphere = () => {
    const pointsRef = useRef();

    let particles = {};

    const model = useGLTF('./model2.glb');

    const positions = model.scene.children.map((child) => {
        return child.geometry.attributes.position;
    });

    // console.log(positions);
    particles.maxCount = 0;

    for (const position of positions) {
        if (position.count > particles.maxCount) {
            particles.maxCount = position.count;
        }
    }

    // console.log(particles.maxCount);

    particles.positions = [];
    for (const position of positions) {
        const originalArray = position.array;

        const newArray = new Float32Array(particles.maxCount * 3);

        for (let i = 0; i < particles.maxCount; i++) {
            const i3 = i * 3;
            if (position.count > 60000) {
                if (i3 < originalArray.length) {
                    newArray[i3] = originalArray[i3];
                    newArray[i3 + 1] = originalArray[i3 + 1];
                    newArray[i3 + 2] = originalArray[i3 + 2];
                } else {
                    const ramdomIndex =
                        Math.floor(position.count * Math.random()) * 3;
                    // console.log(ramdomIndex);

                    newArray[i3] = originalArray[ramdomIndex];
                    newArray[i3 + 1] = originalArray[ramdomIndex + 1];
                    newArray[i3 + 2] = originalArray[ramdomIndex + 2];
                }
            } else {
                if (i3 < originalArray.length) {
                    newArray[i3] = originalArray[i3] * 20.0;
                    newArray[i3 + 1] = originalArray[i3 + 1] * 2.0 + 3.0;
                    newArray[i3 + 2] = originalArray[i3 + 2] * 15.0;
                } else {
                    const ramdomIndex =
                        Math.floor(position.count * Math.random()) * 3;
                    // console.log(ramdomIndex);

                    newArray[i3] = originalArray[ramdomIndex] * 20.0;
                    newArray[i3 + 1] =
                        originalArray[ramdomIndex + 1] * 2.0 + 3.0;
                    newArray[i3 + 2] = originalArray[ramdomIndex + 2] * 15.0;
                }
            }
        }

        // console.log(position.count);

        // for model3
        // {
        //     const i3 = i * 3;
        //     if(position.count > 2000){
        //         if (i3 < originalArray.length) {
        //             newArray[i3] = originalArray[i3] * 3.0;
        //             newArray[i3 + 1] = originalArray[i3 + 1] * 3.0;
        //             newArray[i3 + 2] = originalArray[i3 + 2] * 3.0;
        //         } else {
        //             const ramdomIndex = Math.floor(position.count * Math.random()) * 3;
        //             // console.log(ramdomIndex);

        //             newArray[i3] = originalArray[ramdomIndex] * 3.0;
        //             newArray[i3 + 1] = originalArray[ramdomIndex + 1] * 3.0;
        //             newArray[i3 + 2] = originalArray[ramdomIndex + 2] * 3.0;
        //         }
        //     }else{
        //         if (i3 < originalArray.length) {
        //             newArray[i3] = originalArray[i3] * 2.0;
        //             newArray[i3 + 1] = originalArray[i3 + 1] + 3.0;
        //             newArray[i3 + 2] = originalArray[i3 + 2] * 2.0 ;
        //         } else {
        //             const ramdomIndex = Math.floor(position.count * Math.random()) * 3;
        //             // console.log(ramdomIndex);

        //             newArray[i3] = originalArray[ramdomIndex] * 2.0;
        //             newArray[i3 + 1] = originalArray[ramdomIndex + 1] + 3.0;
        //             newArray[i3 + 2] = originalArray[ramdomIndex + 2] * 2.0;
        //         }
        //     }

        // }

        particles.positions.push(new THREE.Float32BufferAttribute(newArray, 3));
    }

    // console.log(particles.positions);

    const sizesArray = new Float32Array(particles.maxCount);

    for (let i = 0; i < particles.maxCount; i++) {
        sizesArray[i] = Math.random();
    }

    particles.geometry = new THREE.BufferGeometry();
    particles.geometry.setAttribute('position', particles.positions[1]);
    // particles.geometry.setIndex(null);
    particles.geometry.setAttribute('aPositionTarget', particles.positions[0]);
    particles.geometry.setAttribute(
        'aSize',
        new THREE.BufferAttribute(sizesArray, 1)
    );

    const particleControls = useControls('Particles', {
        uSize: { value: 3, min: 0.1, max: 10, step: 0.1 },
        progress: { value: 0, min: 0, max: 1, step: 0.001 },
        TimeFrequency: { value: 0.1, min: 0.0, max: 1.0, step: 0.001 },
        NoiseFreq1: { value: 3.0, min: 0.0, max: 10.0, step: 0.001 },
        NoiseAmplitude1: { value: 0.2, min: 0.0, max: 1.0, step: 0.001 },
        SpeedModifier2: { value: 1.0, min: 0.0, max: 1.0, step: 0.001 },
        NoiseFreq2: { value: 2.0, min: 0.0, max: 10.0, step: 0.001 },
        NoiseAmplitude2: { value: 0.3, min: 0.0, max: 1.0, step: 0.001 },
        SpeedModifier3: { value: 0.8, min: 0.0, max: 1.0, step: 0.001 }
    });

    const particleColorControls = useControls('Particles Colors', {
        colorA: '#EB2329',
        colorB: '#ff0000'
    });

    // Sizes
    const [width, height, pixelRatio] = useAspect(
        window.innerWidth,
        window.innerHeight,
        Math.min(2, window.devicePixelRatio)
    );

    particles.colorA = particleColorControls.colorA;
    particles.colorB = particleColorControls.colorB;

    const uniforms = useMemo(
        () => ({
            uTime: { value: 0 },
            uSize: { value: particleControls.uSize },
            uResolution: {
                value: new THREE.Vector2(
                    width * pixelRatio,
                    height * pixelRatio
                )
            },
            uProgress: { value: particleControls.progress },
            uDistortionFrequency: 2.0,
            uDistortionStrength: 1.0,
            uDisplacementFrequency: 2.0,
            uDisplacementStrength: 0.2,
            uTimeFrequency: 0.1,
            uNoiseFreq1: { value: particleControls.NoiseFreq1 },
            uNoiseAmplitude1: { value: particleControls.NoiseAmplitude1 },
            uSpeedModifier2: { value: particleControls.SpeedModifier2 },
            uNoiseFreq2: { value: particleControls.NoiseFreq2 },
            uNoiseAmplitude2: { value: particleControls.NoiseAmplitude2 },
            uSpeedModifier3: { value: particleControls.SpeedModifier3 },
            uColorA: { value: new THREE.Color(particles.colorA) },
            uColorB: { value: new THREE.Color(particles.colorB) }
        }),
        [
            width,
            height,
            pixelRatio,
            particleControls,
            particles.colorA,
            particles.colorB
        ]
    );

    const material = useMemo(
        () =>
            new THREE.ShaderMaterial({
                vertexShader: particlesVertexShader,
                fragmentShader: particlesFragmentShader,
                uniforms: uniforms,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            }),
        [uniforms]
    );

    useFrame((state) => {
        uniforms.uTime.value = state.clock.elapsedTime;

        // console.log(uniforms.uTime.value);
    });

    useEffect(() => {
        // Update uniforms on resize
        uniforms.uResolution.value.set(width * pixelRatio, height * pixelRatio);
    }, [width, height, pixelRatio, uniforms]);

    const scroll = useScroll();

    useFrame(() => {
        uniforms.uProgress.value = scroll.offset;
    });

    return <points ref={pointsRef} args={[particles.geometry, material]} />;
};

useGLTF.preload('./model2.glb');
export default Sphere;
