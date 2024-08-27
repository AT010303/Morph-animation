import { CameraControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { Perf } from 'r3f-perf';

const Experience = () => {
    return (
        <>
            <Canvas>
                <Perf position={'top-left'} />
                <CameraControls />
                <ambientLight intensity={1} />
                <directionalLight position={[5, 5, 5]} />
                <mesh>
                    <boxGeometry />
                    <meshStandardMaterial color={'lightgreen'} />
                </mesh>
            </Canvas>
        </>
    );
};

export default Experience;
