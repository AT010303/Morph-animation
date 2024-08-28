import { CameraControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { useControls } from 'leva';
import { Perf } from 'r3f-perf';

import Sphere from './Sphere';

const Experience = () => {
    const controls = useControls('experience', {
        backgroundColor: '#111111'
    });

    return (
        <>
            <Canvas
                camera={{
                    fov: 35,
                    position: [0, 0, 8 * 2]
                }}
            >
                <color attach="background" args={[controls.backgroundColor]} />
                <Perf position={'top-left'} />
                <CameraControls />

                <Sphere />
            </Canvas>
        </>
    );
};

export default Experience;
