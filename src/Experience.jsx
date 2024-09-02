import { ScrollControls } from '@react-three/drei';
import { Canvas } from '@react-three/fiber';
import { Leva,useControls } from 'leva';
import { Perf } from 'r3f-perf';

import Sphere from './Sphere';

const Experience = () => {
    const controls = useControls('experience', {
        backgroundColor: '#000308'
    });

    return (
        <>
        <Leva  flat oneLineLabels collapsed />
            <Canvas
                camera={{
                    fov: 35,
                    position: [0, 0.0, 22]
                }}

                className='canvas'
            >
                <color attach="background" args={[controls.backgroundColor]} />
                <Perf position={'bottom-left'} />
                {/* <OrbitControls enabled={true} enableZoom={true} /> */}
                <ScrollControls pages={2} damping={0.65}>
                    <Sphere />
                </ScrollControls>
            </Canvas>
        </>
    );
};

export default Experience;
