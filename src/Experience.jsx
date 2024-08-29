import { OrbitControls, ScrollControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { useControls } from 'leva';
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
                    position: [0, 0.0, 0.15]
                }}
            >
                <color attach="background" args={[controls.backgroundColor]} />
                <fog attach="fog" args={['#f0f0f0', 0, 100]} />
                <Perf position={'top-left'} />
                <OrbitControls enabled={false} enableZoom={false} />
                <ScrollControls pages={2} damping={0.5}>
                    <Sphere />
                </ScrollControls>
            </Canvas>
        </>
    );
};

export default Experience;
