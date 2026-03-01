shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float blur_amount : hint_range(0.0, 100.0) = 10.0;
uniform int quality : hint_range(0, 2) = 1; // 0 = Low, 1 = Medium, 2 = High

const float WEIGHTS_LOW[3] = float[](0.27901, 0.44198, 0.27901);
const float OFFSETS_LOW[3] = float[](-1.0, 0.0, 1.0);

const float WEIGHTS_MEDIUM[5] = float[](0.06136, 0.24477, 0.38774, 0.24477, 0.06136);
const float OFFSETS_MEDIUM[5] = float[](-2.0, -1.0, 0.0, 1.0, 2.0);

const float WEIGHTS_HIGH[9] = float[](0.02324, 0.05586, 0.09973, 0.13327, 0.15558, 0.13327, 0.09973, 0.05586, 0.02324);
const float OFFSETS_HIGH[9] = float[](-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0);

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

void vertex() {
	if (allow_out_of_bounds) {
		float max_expansion = blur_amount * 4.0;
		VERTEX += (UV * 2.0 - 1.0) * max_expansion;
	}
}

void fragment() {
	vec2 uv = UV;
	
	if (allow_out_of_bounds) {
		float max_expansion = blur_amount * 4.0;
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(max_expansion * 2.0));
		uv = (uv - texture_pixel_size * max_expansion) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
	}
	
	vec4 color = vec4(0.0);
	float step_size = blur_amount * TEXTURE_PIXEL_SIZE.y;
	
	if (quality == 0) {
		for (int i = 0; i < 3; i++) {
			vec2 offset = vec2(0.0, OFFSETS_LOW[i] * step_size);
			vec2 sample_uv = uv + offset;
			if (is_inside_usquare(sample_uv)) {
				color += texture(TEXTURE, sample_uv) * WEIGHTS_LOW[i];
			}
		}
	} else if (quality == 1) {
		for (int i = 0; i < 5; i++) {
			vec2 offset = vec2(0.0, OFFSETS_MEDIUM[i] * step_size);
			vec2 sample_uv = uv + offset;
			if (is_inside_usquare(sample_uv)) {
				color += texture(TEXTURE, sample_uv) * WEIGHTS_MEDIUM[i];
			}
		}
	} else {
		for (int i = 0; i < 9; i++) {
			vec2 offset = vec2(0.0, OFFSETS_HIGH[i] * step_size);
			vec2 sample_uv = uv + offset;
			if (is_inside_usquare(sample_uv)) {
				color += texture(TEXTURE, sample_uv) * WEIGHTS_HIGH[i];
			}
		}
	}
	
	COLOR = color;
}