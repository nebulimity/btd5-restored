shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.05);
uniform float circle_x : hint_range(0.0, 1.0);
uniform float circle_y : hint_range(0.0, 1.0);
uniform float screen_width;
uniform float screen_height;

varying float v_ratio;
varying float v_size_sq;

void vertex() {
	v_ratio = screen_width / screen_height;
	v_size_sq = circle_size * circle_size;
}

void fragment() {
	float dx = (UV.x - circle_x) * v_ratio;
	float dy = UV.y - circle_y;
	
	float dist_sq = dx * dx + dy * dy;
	
	COLOR.a = step(v_size_sq, dist_sq);
}