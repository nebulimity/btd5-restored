shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float blur_x: hint_range(0.0, 16.0, 0.1) = 6.0;
uniform float blur_y: hint_range(0.0, 16.0, 0.1) = 6.0;
uniform float strength: hint_range(0.0, 1000.0, 1.0) = 100.0;
uniform vec4 glow_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool knockout = false;

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
        float max_blur = max(blur_x, blur_y);
        if (max_blur > 0.0) {
            VERTEX += (UV * 2.0 - 1.0) * max_blur;
        }
    }
}

void fragment() {
    vec2 uv = UV;
    vec4 texture_color = texture(TEXTURE, UV);

    float max_blur = max(blur_x, blur_y);

    if (allow_out_of_bounds && max_blur > 0.0) {
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(max_blur * 2.0));
        uv = (uv - texture_pixel_size * max_blur) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

        if (is_inside_usquare(uv)) {
            texture_color = texture(TEXTURE, uv);
        } else {
            texture_color = vec4(0.0);
        }
    }

    if (max_blur > 0.0) {
        float glow_alpha = 0.0;
        float total_weight = 0.0;

        int samples_x = int(ceil(blur_x)) * 2 + 1;
        int samples_y = int(ceil(blur_y)) * 2 + 1;

        for (int y = -int(ceil(blur_y)); y <= int(ceil(blur_y)); y++) {
            for (int x = -int(ceil(blur_x)); x <= int(ceil(blur_x)); x++) {
                vec2 offset = vec2(float(x), float(y));

                float weight_x = blur_x > 0.0 ? exp(-0.5 * pow(offset.x / blur_x, 2.0)) : (offset.x == 0.0 ? 1.0 : 0.0);
                float weight_y = blur_y > 0.0 ? exp(-0.5 * pow(offset.y / blur_y, 2.0)) : (offset.y == 0.0 ? 1.0 : 0.0);
                float weight = weight_x * weight_y;

                vec2 sample_uv = uv + offset * TEXTURE_PIXEL_SIZE;

                total_weight += weight;

                if (is_inside_usquare(sample_uv)) {
                    float sample_alpha = texture(TEXTURE, sample_uv).a;
                    glow_alpha += sample_alpha * weight;
                }
            }
        }

        if (total_weight > 0.0) {
            glow_alpha /= total_weight;
        }

        glow_alpha *= (strength / 100.0);

        vec4 glow = vec4(glow_color.rgb, glow_alpha * glow_color.a);

        if (knockout) {
            glow.a *= (1.0 - texture_color.a);
            COLOR = glow;
        } else {
            COLOR = blend(glow, texture_color);
        }
    } else {
        if (knockout) {
            COLOR = vec4(0.0);
        } else {
            COLOR = texture_color;
        }
    }
}