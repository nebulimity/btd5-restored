class_name ArcTile
extends Tile

var center: Vector2
var radius: float
var start_angle: float
var end_angle: float
var clockwise: bool
var arc_length: float
var base_centre: Vector2
var base_start: Vector2
var base_end: Vector2
var reflex: bool

const MAX_SECTION_LENGTH: float = 1.0
var section_length: float

func _init():
	pass

func setup(p_center: Vector2, p_radius: float, p_start_angle: float, p_end_angle: float, p_clockwise: bool):
	center = p_center
	radius = p_radius
	start_angle = p_start_angle
	end_angle = p_end_angle
	clockwise = p_clockwise
	
	var angle_diff = end_angle - start_angle
	if clockwise:
		if angle_diff > 0:
			angle_diff -= TAU
	else:
		if angle_diff < 0:
			angle_diff += TAU
	
	arc_length = abs(angle_diff) * radius
	tile_length = arc_length

func setup_from_three_points(p_centre: Vector2, p_start: Vector2, p_end: Vector2, p_reflex: bool):
	base_centre = p_centre
	base_start = p_start
	base_end = p_end
	reflex = p_reflex
	
	var start_vec = base_start - base_centre
	var end_vec = base_end - base_centre
	radius = start_vec.length()
	
	var dot_product = start_vec.dot(end_vec) / (start_vec.length() * end_vec.length())
	dot_product = clamp(dot_product, -1.0, 1.0)
	var angle_between = acos(dot_product)
	
	if reflex:
		angle_between = TAU - angle_between
	
	tile_length = angle_between * radius
	
	var num_sections = int(ceil(tile_length / MAX_SECTION_LENGTH))
	section_length = tile_length / num_sections
	
	start_angle = atan2(start_vec.y, start_vec.x)
	end_angle = atan2(end_vec.y, end_vec.x)
	
	while end_angle > start_angle and abs(end_angle - start_angle) > PI:
		end_angle -= TAU
	while end_angle < start_angle and abs(end_angle - start_angle) > PI:
		end_angle += TAU
	
	clockwise = not ((end_angle < start_angle and not reflex) or (end_angle > start_angle and reflex))
	
	if reflex and abs(end_angle - start_angle) < PI:
		if clockwise:
			end_angle += TAU
		else:
			end_angle -= TAU
	
	way_points.clear()
	for i in range(num_sections + 1):
		var angle = start_angle + (end_angle - start_angle) * i / num_sections
		var point = base_centre + Vector2(cos(angle), sin(angle)) * radius
		way_points.append(point)

func update_bloon_position(bloon) -> void:
	var section_index = int(floor((way_points.size() - 1) * bloon.tile_progress / tile_length))
	var section_progress = (bloon.tile_progress - section_index * section_length) / section_length
	
	if section_index >= way_points.size() - 1:
		bloon.tile_progress -= tile_length
		if next_tiles.size() > 0:
			bloon.tile = next_tiles[0]
			bloon.update_layer_order()
			bloon.tile.update_bloon_position(bloon)
		else:
			bloon.destroy()
		return
	
	var start_pos = way_points[section_index]
	var end_pos = way_points[section_index + 1]
	bloon.position = start_pos.lerp(end_pos, section_progress)

func get_all_previous_tiles(_result: Array[Tile]) -> void:
	pass
