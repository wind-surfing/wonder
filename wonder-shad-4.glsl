void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    
    float time = iTime * 0.5;
    vec3 camPos = vec3(0.0, 0.0, time);
    vec3 rayDir = normalize(vec3(uv.xy, -1.5));
    
    float angle = sin(time) * 0.5;
    float c = cos(angle);
    float s = sin(angle);
    
    vec3 rayDirRot;
    rayDirRot.x = c * rayDir.x - s * rayDir.z;
    rayDirRot.y = rayDir.y;
    rayDirRot.z = s * rayDir.x + c * rayDir.z;
    rayDir = rayDirRot;
    
    vec3 col = vec3(0.0);
    float t = 0.0;
    
    for (int i = 0; i < 100; i++) {
        vec3 pos = camPos + t * rayDir;
        vec3 p = mod(pos, 4.0) - 2.0;
        
        float d = length(p.xy) - 0.5 + 0.3 * sin(5.0 * p.z + time);
        float glow = 0.03 / (d * d + 0.01);
        
        col += vec3(
            sin(d * 10.0 + time),
            cos(d * 5.0),
            sin(d * 7.0 + time * 1.5)
        ) * glow;
        
        t += 0.05;
        if (t > 20.0) break;
    }
    
    col = 1.0 - exp(-col);
    
    fragColor = vec4(col, 1.0);

}