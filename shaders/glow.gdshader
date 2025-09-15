shader_type canvas_item;
render_mode blend_mix;

const int MAX_RADIUS = 64; // compiled max â raise if you need bigger (costly!)
uniform int blur_radius : hint_range(1, 64) = 55; // user can set up to MAX_RADIUS
uniform float blur_strength : hint_range(0.1, 25.0) = 10.0;

uniform float glow_intensity : hint_range(0.0, 4.0) = 1.0;
uniform float glow_alpha : hint_range(0.0, 1.0) = 1.0;

float gaussian_weight(float i, float sigma) {
    return exp(-0.5 * (i * i) / (sigma * sigma));
}

void calculate_kernel(out float kernel[MAX_RADIUS + 1], int radius, float sigma) {
    float sum = 0.0;
    for (int i = 0; i <= radius; i++) {
        kernel[i] = gaussian_weight(float(i), sigma);
        sum += (i == 0) ? kernel[i] : (2.0 * kernel[i]);
    }
    for (int i = 0; i <= radius; i++) {
        kernel[i] /= sum;
    }
}

void fragment() {
    vec2 uv = UV;

    int r = clamp(blur_radius, 1, MAX_RADIUS);

    float kernel[MAX_RADIUS + 1];
    calculate_kernel(kernel, r, blur_strength);

    vec2 texel = 1.0 / vec2(textureSize(TEXTURE, 0));

    vec3 accum_color = vec3(0.0);
    float accum_alpha = 0.0;

    for (int x = -r; x <= r; x++) {
        for (int y = -r; y <= r; y++) {
            float w = kernel[abs(x)] * kernel[abs(y)];
            vec2 offset = vec2(float(x), float(y)) * texel;
            vec4 sample = texture(TEXTURE, uv + offset);
            accum_color += sample.rgb * sample.a * w;
            accum_alpha += sample.a * w;
        }
    }

    vec3 blurred_color = (accum_alpha > 0.0) ? (accum_color / accum_alpha) : vec3(0.0);
    float blurred_alpha = clamp(accum_alpha, 0.0, 1.0);

    vec4 original = texture(TEXTURE, uv);

    float outside = 1.0 - original.a;
    vec3 glow_color = blurred_color * outside;
    float glow_a = blurred_alpha * outside * glow_alpha;

    vec3 final_rgb = original.rgb + glow_color * glow_intensity;

    float final_alpha = clamp(original.a + glow_a * (1.0 - original.a), 0.0, 1.0);

    COLOR = vec4(final_rgb, final_alpha);
}