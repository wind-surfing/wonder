mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}


float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}

float morphShape(vec3 p) {
    float t = iTime * 0.5;
    float k = fract(t);
    
    int phase = int(mod(floor(t), 3.0));
    
    if (phase == 0) {
        return mix(sdOctahedron(p, 0.15), sdBox(p, vec3(0.15)), k);
    }
    if (phase == 1) {
        return mix(sdBox(p, vec3(0.15)), sdSphere(p, 0.2), k);
    }
    
    return mix(sdSphere(p, 0.2), sdOctahedron(p, 0.15), k);
}

float map(vec3 p) {
    float angle = 0.6 * p.z;
    p.xy *= rot2D(angle);
    
    float angleY = 0.4 * p.z;
    p.xz *= rot2D(angleY);
    
    p.xy = fract(p.xy) - 0.5;
    p.z = mod(p.z, .4) - .2;
    
    return morphShape(p);
}

vec3 palette(float t, float shift) {
    return 0.5 + 0.5*cos(6.28318*(t + vec3(0.3,0.5,0.7) + shift));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    vec2 m = (iMouse.xy * 2. - iResolution.xy) / iResolution.y;
    
    if (iMouse.z <= 0.) m = vec2(cos(iTime * 2.), sin(iTime * .2));
    
    vec3 ro = vec3(0, 0, -3);
    vec3 rd = normalize(vec3(uv, 1));
    vec3 col = vec3(0);
    
    float t = 0.;
    float glow = 0.;
    
    int i;
    for (i = 0; i < 120; i++){
        vec3 p = ro + rd * t;
        p.xy *= rot2D(0.3 * sin(iTime * 0.4));
        p.xz *= rot2D(0.2 * cos(iTime * 0.3));
        
        float d = map(p);
        glow += exp(-15.0 * abs(d));
        t += d;
        if (d < 0.001 || t > 80.) break;
    }
    
    col = palette(t * 0.05 + float(i) * 0.01, iTime * 0.1);
    col += glow * vec3(0.8, 0.3, 1.0);
    col *= exp(-0.02 * t * t);
    fragColor = vec4(col, 1.0);
}