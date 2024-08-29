import { OrbitControls, ScrollControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import {
    Bloom,
    DepthOfField,
    EffectComposer
    // Noise,
    // TiltShift2
} from '@react-three/postprocessing';
import { useControls } from 'leva';
// import { BlendFunction } from 'postprocessing';
import { Perf } from 'r3f-perf';

import Sphere from './Sphere';

const Experience = () => {
    const controls = useControls('experience', {
        backgroundColor: '#000000'
    });

    return (
        <>
            <Canvas
                camera={{
                    fov: 35,
                    position: [0, 0, 14]
                }}
            >
                <color attach="background" args={[controls.backgroundColor]} />
                <fog attach="fog" args={['#f0f0f0', 0, 20]} />
                <Perf position={'top-left'} />
                <OrbitControls enabled={false} enableZoom={false} />
                <ScrollControls pages={2} damping={0.5}>
                    <Sphere />
                </ScrollControls>
                <EffectComposer disableNormalPass multisampling={10}>
                    {/* <TiltShift2 blur={0.03} /> */}
                    <Bloom
                        intensity={0.7}
                        mipmapBlur
                        luminanceThreshold={0.4}
                        luminanceSmoothing={0.25}
                    />
                    {/* <Noise premultiply blendFunction={BlendFunction.ADD} /> */}
                    <DepthOfField
                        focusDistance={1.25} // where to focus
                        focalLength={0.9} // focal length
                        bokehScale={2} // bokeh size
                    />
                </EffectComposer>
            </Canvas>
        </>
    );
};

export default Experience;
