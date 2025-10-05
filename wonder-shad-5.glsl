mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    return (p.x + p.y + p.z - s) * 0.57735027;
}

float smoothMix(float a, float b, float t) {
    t = t * t * (3.0 - 2.0 * t);
    return mix(a, b, t);
}

float morphShape(vec3 p) {
    float t = iTime * 0.3;
    float k = fract(t);
    int phase = int(mod(floor(t), 3.0));
    
    if (phase == 0) return smoothMix(sdOctahedron(p, 0.15), sdBox(p, vec3(0.15)), k);
    if (phase == 1) return smoothMix(sdBox(p, vec3(0.15)), sdSphere(p, 0.2), k);
    
    return smoothMix(sdSphere(p, 0.2), sdOctahedron(p, 0.15), k);
}


float map(vec3 p) {
    float angle = 0.3 * p.z;
    p.xy *= rot2D(angle);
    float angleY = 0.2 * p.z;
    p.xz *= rot2D(angleY);
    p.xy = fract(p.xy) - 0.5;
    p.z = mod(p.z, 0.4) - 0.2;
    return morphShape(p);
}

vec3 palette(float t, float brightness) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.4, 0.4, 0.4);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.1, 0.2);
    
    return a + b * cos(6.28318 * (c * t + d)) * brightness;
}

vec3 getBackground(vec2 uv) {
    float gradient = length(uv) * 0.5;
    return mix(vec3(0.05, 0.1, 0.2), vec3(0.0, 0.0, 0.1), gradient);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
   vec2 m = (iMouse.xy * 2.0 - iResolution.xy) / iResolution.y;
   
   if (iMouse.z <= 0.0) m = vec2(cos(iTime * 0.3), sin(iTime * 0.2));
   
   vec3 ro = vec3(0, 0, -3);
   vec3 rd = normalize(vec3(uv, 1));
   vec3 col = getBackground(uv);
   
   float t = 0.0;
   float glow = 0.0;
   float minDist = 1000.0;
   int i;
   
   for (i = 0; i < 80; i ++) {
       vec3 p = ro + rd * t;
       p.xy *= rot2D(0.1 * sin(iTime * 0.2));
       p.xy *= rot2D(0.1 * cos(iTime * 0.15));
       
       float d = map(p);
       minDist = min(minDist, d);
       
       glow += exp(-5.0 * abs(d)) * 0.02;
       
       t += d * 0.7;
       if (d < 0.01 || t > 50.0) break;
   }
   
   float depthFactor = smoothstep(0.0, 1.0, t * 0.03);
   float iterFactor = float(i) / 80.0;
   float distanceFactor = smoothstep(0.0, 0.5, minDist);
   
   float colorTime = iTime * 0.05 + depthFactor + iterFactor * 0.5;
   
   vec3 baseColor = palette(colorTime, 0.8);
   vec3 accentColor = palette(colorTime + 0.3, 0.6);
   
   col = mix(col, baseColor, 1.0 - distanceFactor);
   col = mix(col, accentColor, glow * 0.3);
   float rim = 1.0 - smoothstep(0.0, 0.3, minDist);
   col += rim * vec3(0.3, 0.5, 0.8) * 0.5;
   col *= exp(-0.008 * t * t);
   
   float vignette = smoothstep(0.0, 1.0, 1.0 - length(uv) * 0.3);
   col *= 0.5 + 0.5 * vignette;
   
   col = col / (1.0 + col);
   col = pow(col, vec3(0.8));
   
   fragColor = vec4(col, 1.0);
}