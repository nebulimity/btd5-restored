shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float shadow_distance : hint_range(0.0, 64.0, 0.1) = 4.0;
uniform float shadow_angle : hint_range(0.0, 360.0, 1.0) = 135.0;
uniform float shadow_strength : hint_range(0.0, 255.0, 0.01) = 0.75; // flash strength (1.0 = 100%)
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float blur_x : hint_range(0.0, 255.0, 0.1) = 0.0;
uniform float blur_y : hint_range(0.0, 255.0, 0.1) = 0.0;
uniform bool inner = false;
uniform bool knockout = false;
uniform bool hide_object = false;

varying flat vec2 v_pad;
varying flat vec2 v_node_scale;

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
	float alpha = top.a + bottom.a * (1.0 - top.a);
	if (alpha < 0.0001) return vec4(0.0);
	vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
	return vec4(color, alpha);
}

float fixed16(float v) {
	return trunc(v * 65536.0) / 65536.0;
}

vec2 flash_offset() {
	float a = fixed16(radians(shadow_angle));
	float d = fixed16(shadow_distance);
	return vec2(cos(a), sin(a)) * d;
}

float blur_pad(float blur, float s) {
	return blur > 1.0 ? ceil((blur - 1.0) / (2.0 * s) + 1.0 / s + 1.0) : 0.0;
}

vec3 box_kernel(float width) {
	width = min(width, 255.0);
	if (width <= 1.0) return vec3(0.0);
	float radius = (width - 1.0) * 0.5;
	float m = ceil(radius) - 1.0;
	float edge = floor((radius - m) * 255.0);
	return vec3(m, edge, width);
}

int floor_div(int num, float den) {
	int q = int(floor(float(num) / den));
	if (float(q + 1) * den <= float(num)) {
		q += 1;
	} else if (float(q) * den > float(num)) {
		q -= 1;
	}
	return q;
}

int alpha_byte(sampler2D tex, ivec2 p, ivec2 size) {
	if (p.x < 0 || p.y < 0 || p.x >= size.x || p.y >= size.y) return 0;
	return int(round(texelFetch(tex, p, 0).a * 255.0));
}

int hblur(sampler2D tex, ivec2 p, ivec2 size, vec3 k) {
	if (k.z <= 0.0) return alpha_byte(tex, p, size);
	int m = int(k.x);
	int sum = alpha_byte(tex, p, size) * 255;
	for (int i = 1; i <= m; i++) {
		sum += (alpha_byte(tex, p + ivec2(i, 0), size) + alpha_byte(tex, p - ivec2(i, 0), size)) * 255;
	}
	ivec2 e = ivec2(m + 1, 0);
	sum += (alpha_byte(tex, p + e, size) + alpha_byte(tex, p - e, size)) * int(k.y);
	return floor_div(sum, 255.0 * k.z);
}

int box_blur_alpha(sampler2D tex, ivec2 p, ivec2 size, vec3 kx, vec3 ky) {
	if (ky.z <= 0.0) return hblur(tex, p, size, kx);
	int m = int(ky.x);
	int sum = hblur(tex, p, size, kx) * 255;
	for (int i = 1; i <= m; i++) {
		sum += (hblur(tex, p + ivec2(0, i), size, kx) + hblur(tex, p - ivec2(0, i), size, kx)) * 255;
	}
	ivec2 e = ivec2(0, m + 1);
	sum += (hblur(tex, p + e, size, kx) + hblur(tex, p - e, size, kx)) * int(ky.y);
	return floor_div(sum, 255.0 * ky.z);
}

void vertex() {
	v_node_scale = max(vec2(length(MODEL_MATRIX[0].xy), length(MODEL_MATRIX[1].xy)), vec2(1e-4));
	v_pad = vec2(0.0);
	if (allow_out_of_bounds) {
		vec2 off = abs(flash_offset()) / v_node_scale;
		vec2 off_pad = vec2(off.x > 0.0 ? ceil(off.x + 1.0) : 0.0, off.y > 0.0 ? ceil(off.y + 1.0) : 0.0);
		v_pad = vec2(blur_pad(blur_x, v_node_scale.x), blur_pad(blur_y, v_node_scale.y)) + off_pad;
		VERTEX += (UV * 2.0 - 1.0) * v_pad;
	}
}

void fragment() {
	vec2 base_size = 1.0 / TEXTURE_PIXEL_SIZE;
	ivec2 isize = textureSize(TEXTURE, 0);
	vec2 raster_size = vec2(isize);
	vec2 ovs = raster_size / base_size;

	vec2 width = ((vec2(blur_x, blur_y) - 1.0) * ovs + 1.0) / v_node_scale;
	width = round(width * 65536.0) / 65536.0;
	vec3 kx = box_kernel(width.x);
	vec3 ky = box_kernel(width.y);

	float d_scale = fixed16(ovs.y);
	vec2 off_screen = flash_offset() * d_scale;
	vec2 off_raster = round(off_screen / v_node_scale * 65536.0) / 65536.0;
	ivec2 shift = ivec2(floor(0.5 - off_raster));

	vec2 uv = (UV * (base_size + 2.0 * v_pad) - v_pad) / base_size;
	vec4 src = is_inside_usquare(uv) ? texture(TEXTURE, uv) : vec4(0.0);

	ivec2 p = ivec2(floor(uv * raster_size));
	float blur = float(box_blur_alpha(TEXTURE, p + shift, isize, kx, ky)) / 255.0;

	float q_strength = floor(shadow_strength * 256.0 + 1e-4) / 256.0;
	float q_alpha = floor(shadow_color.a * 255.0 + 1e-3) / 255.0;

	if (inner) {
		float a = q_alpha * clamp((1.0 - blur) * q_strength, 0.0, 1.0);
		if (knockout || hide_object) {
			COLOR = vec4(shadow_color.rgb, a * src.a);
		} else {
			COLOR = vec4(mix(src.rgb, shadow_color.rgb, a), src.a);
		}
	} else {
		float a = q_alpha * clamp(blur * q_strength, 0.0, 1.0);
		if (knockout) {
			COLOR = vec4(shadow_color.rgb, a * (1.0 - src.a));
		} else if (hide_object) {
			COLOR = vec4(shadow_color.rgb, a);
		} else {
			COLOR = blend(vec4(shadow_color.rgb, a), src);
		}
	}
}