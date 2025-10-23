shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 100.0) = 10.0;
uniform int quality : hint_range(0, 2) = 1; // 0 = Low, 1 = Medium, 2 = High

// Gaussian weights for different quality levels
const float WEIGHTS_LOW[3] = float[](0.27901, 0.44198, 0.27901);
const float OFFSETS_LOW[3] = float[](-1.0, 0.0, 1.0);

const float WEIGHTS_MEDIUM[5] = float[](0.06136, 0.24477, 0.38774, 0.24477, 0.06136);
const float OFFSETS_MEDIUM[5] = float[](-2.0, -1.0, 0.0, 1.0, 2.0);

const float WEIGHTS_HIGH[9] = float[](0.02324, 0.05586, 0.09973, 0.13327, 0.15558, 0.13327, 0.09973, 0.05586, 0.02324);
const float OFFSETS_HIGH[9] = float[](-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0);

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    vec4 color = vec4(0.0);
    
    if (quality == 0) {
        // Low quality - 3 samples
        for (int i = 0; i < 3; i++) {
            vec2 offset = vec2(OFFSETS_LOW[i] * blur_amount * pixel_size.x, 0.0);
            color += texture(TEXTURE, UV + offset) * WEIGHTS_LOW[i];
        }
    } else if (quality == 1) {
        // Medium quality - 5 samples
        for (int i = 0; i < 5; i++) {
            vec2 offset = vec2(OFFSETS_MEDIUM[i] * blur_amount * pixel_size.x, 0.0);
            color += texture(TEXTURE, UV + offset) * WEIGHTS_MEDIUM[i];
        }
    } else {
        // High quality - 9 samples
        for (int i = 0; i < 9; i++) {
            vec2 offset = vec2(OFFSETS_HIGH[i] * blur_amount * pixel_size.x, 0.0);
            color += texture(TEXTURE, UV + offset) * WEIGHTS_HIGH[i];
        }
    }
    
    COLOR = color;
}