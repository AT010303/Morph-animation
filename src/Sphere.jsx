import { useAspect, useGLTF } from '@react-three/drei';
import { useControls } from 'leva';
import { useEffect, useMemo, useRef } from 'react';
import * as THREE from 'three';

import particlesFragmentShader from './shaders/particles/fragment.glsl';
import particlesVertexShader from './shaders/particles/vertex.glsl';

const Sphere = () => {
    const pointsRef = useRef();

    let particles = {};

    const model = useGLTF('./model.glb');

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

            if (i3 < originalArray.length) {
                newArray[i3] = originalArray[i3];
                newArray[i3 + 1] = originalArray[i3 + 1];
                newArray[i3 + 2] = originalArray[i3 + 2];
            } else {

                const ramdomIndex = Math.floor(position.count * Math.random()) * 3;
                // console.log(ramdomIndex);
                
                newArray[i3] = originalArray[ramdomIndex];
                newArray[i3 + 1] = originalArray[ramdomIndex + 1];
                newArray[i3 + 2] = originalArray[ramdomIndex + 2];
            }
        }

        particles.positions.push(new THREE.Float32BufferAttribute(newArray, 3));
    }

    // console.log(particles.positions);

    particles.geometry = new THREE.BufferGeometry();
    particles.geometry.setAttribute('position', particles.positions[0]);
    // particles.geometry.setIndex(null);
    particles.geometry.setAttribute("aPositionTarget", particles.positions[1]);

    const particleControls = useControls('Particles', {
        uSize: { value: 4, min: 0.1, max: 10, step: 0.1 },
        progress: { value: 0, min:0, max:1, step:0.001 }
    });

    // Sizes
    const [width, height, pixelRatio] = useAspect(
        window.innerWidth,
        window.innerHeight,
        Math.min(2, window.devicePixelRatio)
    );

    const uniforms = useMemo(
        () => ({
            uSize: { value: particleControls.uSize },
            uResolution: {
                value: new THREE.Vector2(
                    width * pixelRatio,
                    height * pixelRatio
                )
            },
            uProgress: {value: particleControls.progress},
        }),
        [width, height, pixelRatio, particleControls]
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

    // Geometry
    // const geometry = useMemo(() => {
    //     const geo = new THREE.SphereGeometry(3);
    //     geo.setIndex(null);
    //     return geo;
    // }, []);

    useEffect(() => {
        // Update uniforms on resize
        uniforms.uResolution.value.set(width * pixelRatio, height * pixelRatio);
    }, [width, height, pixelRatio, uniforms]);

    return <points ref={pointsRef} args={[particles.geometry, material]} />;
};

export default Sphere;
