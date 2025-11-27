shader_type canvas_item;

uniform float brightness: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float contrast: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float saturation: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float hue: hint_range(-180.0, 180.0, 1.0) = 0.0;

vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    if (color.a > 0.0) {
        vec3 rgb = color.rgb;
        
        if (brightness != 0.0) {
            float b = brightness / 100.0;
            rgb += b;
        }
        
        if (contrast != 0.0) {
            float c = (contrast / 100.0) + 1.0;
            rgb = (rgb - 0.5) * c + 0.5;
        }
        
        if (saturation != 0.0 || hue != 0.0) {
            vec3 hsv = rgb_to_hsv(rgb);
            
            if (saturation != 0.0) {
                float s = saturation / 100.0;
                hsv.y = clamp(hsv.y + s, 0.0, 1.0);
            }
            
            if (hue != 0.0) {
                float h = hue / 360.0;
                hsv.x = fract(hsv.x + h);
            }
            
            rgb = hsv_to_rgb(hsv);
        }
        
        rgb = clamp(rgb, 0.0, 1.0);
        
        COLOR = vec4(rgb, color.a); 
    } else {
        COLOR = color;
    }
}