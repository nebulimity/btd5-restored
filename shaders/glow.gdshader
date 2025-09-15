shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int blur_radius : hint_range(1, 32) = 32;
uniform float blur_strength : hint_range(0.1, 10.0) = 10.0;
uniform float Darkness : hint_range(0.0,1.0) = 0.0;
uniform float R : hint_range(0.0,1.0) = 0.0;
uniform float G : hint_range(0.0,1.0) = 0.0;
uniform float B : hint_range(0.0,1.0) = 0.0;

uniform float glow_intensity : hint_range(0.0, 4.0) = 1.0;
uniform float glow_alpha : hint_range(0.0, 1.0) = 1.0;

float gaussian_weight(float i, float sigma) {
    return exp(-0.5 * (i * i) / (sigma * sigma));
}

void calculate_kernel(out float kernel[32], int radius, float sigma) {
    float sum = 0.0;
    for (int i = 0; i <= radius; i++) {
        kernel[i] = gaussian_weight(float(i), sigma);
        sum += i == 0 ? kernel[i] : 2.0 * kernel[i];
    }
    for (int i = 0; i <= radius; i++) {
        kernel[i] /= sum;
    }
}

void fragment() {
    vec2 uv = UV;

    float kernel[32];
    calculate_kernel(kernel, blur_radius, blur_strength);

    vec2 texel = 1.0 / vec2(textureSize(TEXTURE, 0));

    vec3 accum_color = vec3(0.0);
    float accum_alpha = 0.0;

    for (int x = -blur_radius; x <= blur_radius; x++) {
        for (int y = -blur_radius; y <= blur_radius; y++) {
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

    blurred_color.r = (blurred_color.r + R) - Darkness;
    blurred_color.g = (blurred_color.g + G) - Darkness;
    blurred_color.b = (blurred_color.b + B) - Darkness;

    vec3 glow_color = max(blurred_color - original.rgb, 0.0);
    float glow_a = max(blurred_alpha - original.a, 0.0) * glow_alpha;

    vec3 final_color = original.rgb + glow_color * glow_intensity;
    float final_alpha = max(original.a, glow_a);

    COLOR = vec4(final_color, final_alpha);
}