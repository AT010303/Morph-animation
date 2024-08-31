import { OrbitControls, ScrollControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { Leva,useControls } from 'leva';
import { Perf } from 'r3f-perf';

import Sphere from './Sphere';

const Experience = () => {
    const controls = useControls('experience', {
        backgroundColor: '#070010'
    });

    return (
        <>
        <Leva  flat oneLineLabels collapsed />
            <Canvas
                camera={{
                    fov: 35,
                    position: [0, 0.0, 18]
                }}
            >
                
                <color attach="background" args={[controls.backgroundColor]} />
                <fog attach="fog" args={['#f0f0f0', 0, 100]} />
                <Perf position={'top-left'} />
                <OrbitControls enabled={false} enableZoom={false} />
                <ScrollControls pages={2} damping={0.7}>
                    <Sphere />
                </ScrollControls>
            </Canvas>
        </>
    );
};

export default Experience;
