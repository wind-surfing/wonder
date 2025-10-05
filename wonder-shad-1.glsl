vec3 palette(float t) {
    vec3 a = vec3(0.3, 0.4, 0.5);  
    vec3 b = vec3(0.3, 0.3, 0.3);  
    vec3 c = vec3(1.0, 1.0, 1.0);  
    vec3 d = vec3(0.2, 0.5, 0.7);   

    return a + b * cos(6.28318 * (c * t + d));
}

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
}

float smoothNoise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t = iTime * 0.05;
    float n1 = smoothNoise(uv * 1.5 + vec2(t, 0.0));
    float n2 = smoothNoise(uv * 2.5 - vec2(0.0, t));
    float n3 = smoothNoise(uv * 0.7 + vec2(t * 0.3, t * 0.2));
    float pattern = n1 * 0.5 + n2 * 0.3 + n3 * 0.7;
    vec3 col = palette(pattern + t * 0.2);

    float vignette = smoothstep(1.2, 0.2, length(uv));
    col *= vignette;
    col = pow(col, vec3(0.9));

    fragColor = vec4(col, 1.0);
}
