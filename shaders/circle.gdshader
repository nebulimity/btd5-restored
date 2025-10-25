shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.05);
uniform float circle_x : hint_range(0.0, 1.0);
uniform float circle_y : hint_range(0.0, 1.0);
uniform float screen_width;
uniform float screen_height;

void fragment() {
	float ratio = screen_width / screen_height;
	float dist = distance(vec2(circle_x, circle_y), vec2(mix(circle_x, UV.x, ratio), UV.y));
	COLOR.a = step(circle_size, dist);
}