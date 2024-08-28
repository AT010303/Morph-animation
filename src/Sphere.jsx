import { useAspect } from '@react-three/drei';
import { useControls } from 'leva';
import { useEffect, useMemo, useRef } from 'react';
import * as THREE from 'three';

import particlesFragmentShader from './shaders/particles/fragment.glsl';
import particlesVertexShader from './shaders/particles/vertex.glsl';

const Sphere = () => {
    const pointsRef = useRef();

    const particleControls = useControls('Particles', {
        uSize: { value: 15, min: 0.1, max: 50, step: 1 }
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
            }
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
    const geometry = useMemo(() => {
        const geo = new THREE.SphereGeometry(3);
        geo.setIndex(null);
        return geo;
    }, []);

    useEffect(() => {
        // Update uniforms on resize
        uniforms.uResolution.value.set(width * pixelRatio, height * pixelRatio);
    }, [width, height, pixelRatio, uniforms]);

    return <points ref={pointsRef} args={[geometry, material]} />;
};

export default Sphere;
