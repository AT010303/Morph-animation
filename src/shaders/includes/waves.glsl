//refrence



// Basic wave function that returns a sine wave value based on position and size
float wave(float x, float size) {
    float position = mod(x, 1.0);
    if (position > 0.0 && position < size) {
        float progress = position / size;
        return sin(smoothstep(0.0, 1.0, progress) * PI);
    } else {
        return 0.0;
    }
}

// Generates complex wave patterns by combining multiple wave effects
float waves(vec3 position) {
    float velocity = uTime * uTimeFrequency;
    float velocityAnimated = (uTime + uProgress * 10.0) * uTimeFrequency;
    float x = position.x / uResolution.x; // normalized x position
    float z = position.z / uResolution.y; // normalized z position

    // Create various wave patterns with different parameters
    float wave1 = wave(x + velocity * 0.02, 0.5) * wave(z - 0.25, 0.3) * 0.3;
    float wave2 = wave1 + wave(x + velocity * 0.02 - 0.05, 0.2) * wave(z - 0.25, 0.3) * 0.3;
    float wave6 = wave(x + velocity * 0.01 + 0.3, 0.5) * wave(z - 0.1, 0.3) * 0.3;
    float wave7 = wave(x + velocity * 0.03 - 0.3, 0.5) * wave(z - 0.15, 0.2) * 0.3;

    // Larger waves with complex sine and cosine modulation
    float waveMidLarge = cos(clamp(z * 10.0 + sin(x * 10.0 * 0.5 + velocityAnimated * 0.07) * 3.0, -PI, PI)) * 0.5 + 0.5;
    waveMidLarge = pow(abs(waveMidLarge), 4.0) * sin(x * 10.0 * 0.5 + velocity * 0.1) * 0.7;

    float waveMidMedium = cos(clamp(z * 25.0 + sin(x * 25.0 * 0.5 + velocity * 0.1) * 3.0, -PI, PI)) * 0.5 + 0.5;
    waveMidMedium = pow(abs(waveMidMedium), 4.0) * sin(x * 10.0 * 0.5 + velocityAnimated * 0.1) * 0.3;

    // Soft and small waves with variations for adding more texture
    float waveBackLargeSoft1 = wave(x + velocity * 0.01 + 0.4, 0.5) * wave(z - 0.3, 1.0) * 0.6;
    float waveBackLargeSoft2 = wave(x + velocity * 0.012 + 0.6, 0.5) * wave(z - 0.23, 1.0) * 0.6;

    float waveSmallSoft1 = (sin(x * 100.0 + velocity * 0.3) + cos(x * 80.0 + velocity * 0.4) + sin(x * 60.0 + velocity * 0.5)) * 0.05;
    waveSmallSoft1 *= wave(z + 0.8, 0.2);

    float waveSmallSoft2 = (sin(x * 95.0 + velocity * 0.5) + cos(x * 75.0 + velocity * 0.4) + sin(x * 55.0 + velocity * 0.3)) * 0.075;
    waveSmallSoft2 *= wave(z + 0.65, 0.2);

    float waveSmallSoft3 = (sin(x * 70.0 + velocityAnimated * 0.45) + cos(x * 50.0 + velocity * 0.35) + sin(x * 30.0 + velocityAnimated * 0.45)) * 0.1;
    waveSmallSoft3 *= wave(z + 0.95, 0.2);

    float waveSmallSoft4 = (sin(x * 60.0 + velocity * 0.35) + cos(x * 40.0 + velocityAnimated * 0.55) + sin(x * 20.0 + velocity * 0.5)) * 0.075;
    waveSmallSoft4 *= wave(z + 1.1, 0.2);

    float waveZ = sin(z * 20.0 + velocity * -0.2) * 0.1;

    // Slope effect for adjusting wave height
    float slope = x * -2.0;
    float waveHeight = uSize; // Scaling the wave heights

    // Combine all wave components
    return (wave1 + wave2 + wave6 + wave7 + waveMidLarge + waveMidMedium + waveBackLargeSoft1 +
            waveBackLargeSoft2 + waveSmallSoft1 + waveSmallSoft2 + waveSmallSoft3 + waveSmallSoft4 +
            waveZ + slope) * (1.0 - smoothstep(0.4, 0.55, z)) * waveHeight;
}
