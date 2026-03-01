shader_type canvas_item;

uniform float brightness: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float contrast: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float saturation: hint_range(-100.0, 100.0, 1.0) = 0.0;
uniform float hue: hint_range(-180.0, 180.0, 1.0) = 0.0;

varying float v_brightness;
varying float v_contrast;
varying float v_saturation;
varying float v_hue;

void vertex() {
	v_brightness = brightness / 100.0;
	v_contrast = (contrast / 100.0) + 1.0;
	v_saturation = saturation / 100.0;
	v_hue = hue / 360.0;
}

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
	
	if (color.a > 0.001) {
		vec3 rgb = color.rgb;
		
		if (v_brightness != 0.0) {
			rgb += v_brightness;
		}
		
		if (v_contrast != 1.0) {
			rgb = (rgb - 0.5) * v_contrast + 0.5;
		}
		
		if (v_saturation != 0.0 || v_hue != 0.0) {
			vec3 hsv = rgb_to_hsv(rgb);
			
			if (v_saturation != 0.0) {
				hsv.y = clamp(hsv.y + v_saturation, 0.0, 1.0);
			}
			
			if (v_hue != 0.0) {
				hsv.x = fract(hsv.x + v_hue);
			}
			
			rgb = hsv_to_rgb(hsv);
		}
		
		rgb = clamp(rgb, 0.0, 1.0);
		
		COLOR = vec4(rgb, color.a); 
	} else {
		COLOR = color;
	}
}