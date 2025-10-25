shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float shadow_distance: hint_range(0.0, 32.0, 1.0) = 4.0;
uniform float shadow_angle: hint_range(0.0, 360.0, 1.0) = 135.0;
uniform float shadow_strength: hint_range(0.0, 1.0, 0.01) = 0.75;
uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

bool is_inside_usquare(vec2 x) {
    return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
    float alpha = top.a + bottom.a * (1.0 - top.a);
    if (alpha < 0.0001) return vec4(0.0);
    vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
    return vec4(color, alpha);
}

void vertex() {
    if (allow_out_of_bounds && shadow_distance > 0.0) {
        VERTEX += (UV * 2.0 - 1.0) * shadow_distance;
    }
}

void fragment() {
    vec2 uv = UV;
    vec4 texture_color = texture(TEXTURE, UV);
    
    if (allow_out_of_bounds && shadow_distance > 0.0) {
        // Adjust UV coordinates for expanded bounds
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(shadow_distance * 2.0));
        uv = (uv - texture_pixel_size * shadow_distance) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
        
        if (is_inside_usquare(uv)) {
            texture_color = texture(TEXTURE, uv);
        } else {
            texture_color = vec4(0.0);
        }
    }
    
    float angle_rad = radians(shadow_angle);
    vec2 shadow_offset = vec2(cos(angle_rad), sin(angle_rad)) * shadow_distance * TEXTURE_PIXEL_SIZE;
    
    vec2 shadow_uv = uv - shadow_offset;
    vec4 shadow = vec4(0.0);
    
    if (is_inside_usquare(shadow_uv)) {
        float shadow_alpha = texture(TEXTURE, shadow_uv).a;
        shadow = vec4(shadow_color.rgb, shadow_alpha * shadow_color.a * shadow_strength);
    }
    
    COLOR = blend(shadow, texture_color);
}