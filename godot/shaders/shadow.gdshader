shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float shadow_distance: hint_range(0.0, 32.0, 1.0) = 4.0;
uniform float shadow_angle: hint_range(0.0, 360.0, 1.0) = 135.0;
uniform float shadow_strength: hint_range(0.0, 1.0, 0.01) = 0.75;
uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float blur_x: hint_range(0.0, 16.0, 0.1) = 0.0;
uniform float blur_y: hint_range(0.0, 16.0, 0.1) = 0.0;

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
    if (allow_out_of_bounds) {
        float max_expansion = shadow_distance + max(blur_x, blur_y);
        VERTEX += (UV * 2.0 - 1.0) * max_expansion;
    }
}

void fragment() {
    vec2 uv = UV;
    vec4 texture_color = texture(TEXTURE, UV);

    if (allow_out_of_bounds) {
        float max_expansion = shadow_distance + max(blur_x, blur_y);
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(max_expansion * 2.0));
        uv = (uv - texture_pixel_size * max_expansion) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

        if (is_inside_usquare(uv)) {
            texture_color = texture(TEXTURE, uv);
        } else {
            texture_color = vec4(0.0);
        }
    }

    float angle_rad = radians(shadow_angle);
    vec2 shadow_offset = vec2(cos(angle_rad), sin(angle_rad)) * shadow_distance * TEXTURE_PIXEL_SIZE;

    vec4 shadow = vec4(0.0);

    if (blur_x > 0.0 || blur_y > 0.0) {
        float total_weight = 0.0;
        float shadow_alpha_sum = 0.0;

        int samples_x = int(ceil(blur_x)) * 2 + 1;
        int samples_y = int(ceil(blur_y)) * 2 + 1;

        for (int y = 0; y < samples_y; y++) {
            for (int x = 0; x < samples_x; x++) {
                float offset_x = (float(x) - float(samples_x - 1) * 0.5) * (blur_x / float(samples_x - 1)) * 2.0;
                float offset_y = (float(y) - float(samples_y - 1) * 0.5) * (blur_y / float(samples_y - 1)) * 2.0;

                vec2 blur_offset = vec2(offset_x, offset_y) * TEXTURE_PIXEL_SIZE;
                vec2 sample_uv = uv - shadow_offset + blur_offset;

                float weight = exp(-(offset_x * offset_x + offset_y * offset_y) * 0.5);
                total_weight += weight;

                if (is_inside_usquare(sample_uv)) {
                    shadow_alpha_sum += texture(TEXTURE, sample_uv).a * weight;
                }
            }
        }

        if (total_weight > 0.0) {
            float shadow_alpha = shadow_alpha_sum / total_weight;
            shadow = vec4(shadow_color.rgb, shadow_alpha * shadow_color.a * shadow_strength);
        }
    } else {
        vec2 shadow_uv = uv - shadow_offset;

        if (is_inside_usquare(shadow_uv)) {
            float shadow_alpha = texture(TEXTURE, shadow_uv).a;
            shadow = vec4(shadow_color.rgb, shadow_alpha * shadow_color.a * shadow_strength);
        }
    }

    COLOR = blend(shadow, texture_color);
}