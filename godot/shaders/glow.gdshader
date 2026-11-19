shader_type canvas_item;

uniform bool allow_out_of_bounds = true;
uniform float blur_x : hint_range(0.0, 255.0, 0.1) = 6.0;
uniform float blur_y : hint_range(0.0, 255.0, 0.1) = 6.0;
uniform float strength : hint_range(0.0, 255.0, 0.01) = 2.0; // flash strength (1.0 = 100%)
uniform int quality : hint_range(0, 3) = 1;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool knockout = false;
uniform bool scale_blur_with_oversampling = true;

varying flat vec2 v_pad;
varying flat vec2 v_node_scale;

const int HALF = 15;
const int WIN = 32;

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
	float alpha = top.a + bottom.a * (1.0 - top.a);
	if (alpha < 0.0001) return vec4(0.0);
	vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
	return vec4(color, alpha);
}

float local_pad(float blur, float s, int passes) {
	return blur > 0.0 ? ceil(float(max(passes, 1)) * (blur / s + 1.0)) : 0.0;
}

vec3 box_kernel(float width) {
	width = min(width, 255.0);
	if (width <= 1.0) return vec3(0.0);
	float radius = (width - 1.0) * 0.5;
	float m = ceil(radius) - 1.0;
	float edge = floor((radius - m) * 255.0);
	return vec3(m, edge, width);
}

int kernel_reach(vec3 k) {
	return k.z > 0.0 ? int(k.x) + 1 : 0;
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

// quality 1

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

// quality 2

float windowed_blur_alpha(sampler2D tex, vec2 f, ivec2 size, vec2 width, int passes) {
	vec3 kx = box_kernel(width.x);
	vec3 ky = box_kernel(width.y);
	int stride = 1;
	if (passes * max(kernel_reach(kx), kernel_reach(ky)) > HALF) {
		int need = passes * max(kernel_reach(kx), kernel_reach(ky));
		stride = max(2, int(ceil(float(need) / float(HALF - 1))));
		for (int t = 0; t < 8; t++) {
			kx = box_kernel(width.x / float(stride));
			ky = box_kernel(width.y / float(stride));
			if (passes * max(kernel_reach(kx), kernel_reach(ky)) <= HALF - 1) break;
			stride += 1;
		}
	}
	int rx = kernel_reach(kx);
	int ry = kernel_reach(ky);
	int hx = passes * rx;
	int hy = passes * ry;

	int ext = stride > 1 ? 1 : 0;
	vec2 g = stride > 1 ? (f - 0.5) / float(stride) : floor(f);
	ivec2 g0 = ivec2(floor(g));
	vec2 t = g - floor(g);

	int win[WIN * WIN];
	for (int j = 0; j <= 2 * hy + ext; j++) {
		for (int i = 0; i <= 2 * hx + ext; i++) {
			win[j * WIN + i] = alpha_byte(tex, (g0 + ivec2(i - hx, j - hy)) * stride, size);
		}
	}

	int x0 = 0;
	int x1 = 2 * hx + ext;
	int y0 = 0;
	int y1 = 2 * hy + ext;
	int line[WIN];

	for (int pass = 0; pass < passes; pass++) {
		if (rx > 0) {
			int m = int(kx.x);
			int e = int(kx.y);
			float den = 255.0 * kx.z;
			for (int j = y0; j <= y1; j++) {
				for (int i = x0; i <= x1; i++) line[i] = win[j * WIN + i];
				for (int i = x0 + rx; i <= x1 - rx; i++) {
					int sum = line[i] * 255;
					for (int d = 1; d <= m; d++) sum += (line[i + d] + line[i - d]) * 255;
					sum += (line[i + m + 1] + line[i - m - 1]) * e;
					win[j * WIN + i] = floor_div(sum, den);
				}
			}
			x0 += rx;
			x1 -= rx;
		}
		if (ry > 0) {
			int m = int(ky.x);
			int e = int(ky.y);
			float den = 255.0 * ky.z;
			for (int i = x0; i <= x1; i++) {
				for (int j = y0; j <= y1; j++) line[j] = win[j * WIN + i];
				for (int j = y0 + ry; j <= y1 - ry; j++) {
					int sum = line[j] * 255;
					for (int d = 1; d <= m; d++) sum += (line[j + d] + line[j - d]) * 255;
					sum += (line[j + m + 1] + line[j - m - 1]) * e;
					win[j * WIN + i] = floor_div(sum, den);
				}
			}
			y0 += ry;
			y1 -= ry;
		}
	}
	float a00 = float(win[hy * WIN + hx]);
	if (ext == 0) return a00;
	float a10 = float(win[hy * WIN + hx + 1]);
	float a01 = float(win[(hy + 1) * WIN + hx]);
	float a11 = float(win[(hy + 1) * WIN + hx + 1]);
	return mix(mix(a00, a10, t.x), mix(a01, a11, t.x), t.y);
}

void vertex() {
	v_node_scale = max(vec2(length(MODEL_MATRIX[0].xy), length(MODEL_MATRIX[1].xy)), vec2(1e-4));
	v_pad = vec2(0.0);
	if (allow_out_of_bounds) {
		v_pad = vec2(local_pad(blur_x, v_node_scale.x, quality), local_pad(blur_y, v_node_scale.y, quality));
		VERTEX += (UV * 2.0 - 1.0) * v_pad;
	}
}

void fragment() {
	vec2 base_size = 1.0 / TEXTURE_PIXEL_SIZE;
	ivec2 isize = textureSize(TEXTURE, 0);
	vec2 raster_size = vec2(isize);
	vec2 ovs = raster_size / base_size;

	vec2 uv = (UV * (base_size + 2.0 * v_pad) - v_pad) / base_size;
	vec4 src = is_inside_usquare(uv) ? texture(TEXTURE, uv) : vec4(0.0);

	if (knockout && src.a >= 1.0) {
		COLOR = vec4(glow_color.rgb, 0.0);
	} else {
		vec2 b = vec2(blur_x, blur_y);
		vec2 width = scale_blur_with_oversampling ? ((b - 1.0) * ovs + 1.0) / v_node_scale : b / v_node_scale;
		width = round(width * 65536.0) / 65536.0;
		vec3 kx = box_kernel(width.x);
		vec3 ky = box_kernel(width.y);

		vec2 f = uv * raster_size;
		ivec2 p = ivec2(floor(f));
		float blurred;
		if (quality <= 0) {
			blurred = float(alpha_byte(TEXTURE, p, isize));
		} else if (quality == 1 && max(kernel_reach(kx), kernel_reach(ky)) <= HALF) {
			blurred = float(box_blur_alpha(TEXTURE, p, isize, kx, ky));
		} else {
			blurred = windowed_blur_alpha(TEXTURE, f, isize, width, quality);
		}
		float blur = blurred / 255.0;

		float q_strength = floor(strength * 256.0 + 1e-4) / 256.0;
		float q_alpha = floor(glow_color.a * 255.0 + 1e-3) / 255.0;
		float g = q_alpha * clamp(blur * q_strength, 0.0, 1.0);

		if (knockout) {
			COLOR = vec4(glow_color.rgb, g * (1.0 - src.a));
		} else {
			COLOR = blend(vec4(glow_color.rgb, g), src);
		}
	}
}