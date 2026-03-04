class_name TerrainType
extends RefCounted

const PLAY_AREA_WIDTH: int = 700
const PLAY_AREA_HEIGHT: int = 520
const STANDARD_PRECISION_SCALE: float = 0.25

var test_map: Image
var scaled_width: int
var scaled_height: int

func _init() -> void:
	scaled_width = ceili(PLAY_AREA_WIDTH * STANDARD_PRECISION_SCALE)
	scaled_height = ceili(PLAY_AREA_HEIGHT * STANDARD_PRECISION_SCALE)
	test_map = Image.create_empty(scaled_width, scaled_height, false, Image.FORMAT_RGBA8)

func draw_to_map(texture: Texture2D, top_left_pos: Vector2, world_scale: Vector2 = Vector2.ONE) -> void:
	var img = texture.get_image()
	img.convert(Image.FORMAT_RGBA8)
	var world_size = texture.get_size() * world_scale
	var sw = max(1, ceili(world_size.x * STANDARD_PRECISION_SCALE))
	var sh = max(1, ceili(world_size.y * STANDARD_PRECISION_SCALE))
	img.resize(sw, sh, Image.INTERPOLATE_BILINEAR)
	
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.001:
				img.set_pixel(x, y, Color(1, 1, 1, 1))

	var scaled_pos = top_left_pos * STANDARD_PRECISION_SCALE
	
	for fy in range(sh):
		var m_y_start = floori(scaled_pos.y + fy)
		var m_y_end = ceili(scaled_pos.y + fy + 1.0)
		for fx in range(sw):
			if img.get_pixel(fx, fy).a > 0.0:
				var m_x_start = floori(scaled_pos.x + fx)
				var m_x_end = ceili(scaled_pos.x + fx + 1.0)
				for my in range(m_y_start, m_y_end):
					for mx in range(m_x_start, m_x_end):
						if mx >= 0 and mx < scaled_width and my >= 0 and my < scaled_height:
							test_map.set_pixel(mx, my, Color(1, 1, 1, 1))

func is_outside(scaled_footprint: Image, world_pos: Vector2, texture_offset: Vector2 = Vector2.ZERO) -> bool:
	var scaled_pos = (world_pos + texture_offset) * STANDARD_PRECISION_SCALE
	var fp_w = scaled_footprint.get_width()
	var fp_h = scaled_footprint.get_height()
	
	for fy in range(fp_h):
		var m_y_start = floori(scaled_pos.y + fy)
		var m_y_end = ceili(scaled_pos.y + fy + 1.0)
		
		for fx in range(fp_w):
			if scaled_footprint.get_pixel(fx, fy).a > 0.0:
				var m_x_start = floori(scaled_pos.x + fx)
				var m_x_end = ceili(scaled_pos.x + fx + 1.0)
				
				for my in range(m_y_start, m_y_end):
					for mx in range(m_x_start, m_x_end):
						if mx < 0 or mx >= scaled_width or my < 0 or my >= scaled_height:
							return false
						
						if test_map.get_pixel(mx, my).a > 0.0:
							return false
	return true

func is_within(scaled_footprint: Image, world_pos: Vector2, texture_offset: Vector2 = Vector2.ZERO) -> bool:
	var scaled_pos = (world_pos + texture_offset) * STANDARD_PRECISION_SCALE
	var fp_w = scaled_footprint.get_width()
	var fp_h = scaled_footprint.get_height()
	
	for fy in range(fp_h):
		var m_y_start = floori(scaled_pos.y + fy)
		var m_y_end = ceili(scaled_pos.y + fy + 1.0)
		for fx in range(fp_w):
			if scaled_footprint.get_pixel(fx, fy).a > 0.0:
				var m_x_start = floori(scaled_pos.x + fx)
				var m_x_end = ceili(scaled_pos.x + fx + 1.0)
				for my in range(m_y_start, m_y_end):
					for mx in range(m_x_start, m_x_end):
						if mx < 0 or mx >= scaled_width or my < 0 or my >= scaled_height:
							return false
						if test_map.get_pixel(mx, my).a == 0.0:
							return false
	return true
