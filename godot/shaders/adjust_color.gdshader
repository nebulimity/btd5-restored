shader_type canvas_item;

uniform vec4 red_row = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec4 green_row = vec4(0.0, 1.0, 0.0, 0.0);
uniform vec4 blue_row = vec4(0.0, 0.0, 1.0, 0.0);
uniform vec4 alpha_row = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 offsets = vec4(0.0); // [4], [9], [14], [19]

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	vec4 c = vec4(src.a > 0.0 ? src.rgb : vec3(0.0), src.a);
	vec4 result = vec4(dot(red_row, c), dot(green_row, c), dot(blue_row, c), dot(alpha_row, c));
	COLOR = clamp(result + offsets / 255.0, 0.0, 1.0);
}