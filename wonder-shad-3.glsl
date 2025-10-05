void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    vec2 pos = uv - 0.5;
    pos.x *= iResolution.x / iResolution.y;

    float t = iTime * 0.3;

    float wave1 = sin(pos.y * 8.0 + t * 4.0) * 0.2;
    float wave2 = cos(pos.y * 6.0 - t * 2.0) * 0.15;
    float wave  = wave1 + wave2;

    vec3 col = mix(vec3(0.1, 0.0, 0.2),
                   vec3(0.0, 0.5, 0.8),
                   uv.y);

    col += 0.4 * vec3(
        sin(t + pos.y * 5.0),
        sin(t + pos.y * 7.0 + 2.0),
        sin(t + pos.y * 9.0 + 4.0)  
    ) * (0.5 + wave);

    float vignette = smoothstep(0.8, 0.2, length(pos));
    col *= vignette;

    fragColor = vec4(col, 1.0);
}
