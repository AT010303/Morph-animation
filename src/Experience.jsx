import { CameraControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { Perf } from 'r3f-perf';

import Sphere from './Sphere';

const Experience = () => {
    return (
        <>
            <Canvas camera={{
                fov: 35,
                position: [0, 0, 8*2],
            }}>
                <color attach="background" args={['#111111']} />
                <Perf position={'top-left'} />
                <CameraControls />

                <Sphere />
            </Canvas>
        </>
    );
};

export default Experience;
