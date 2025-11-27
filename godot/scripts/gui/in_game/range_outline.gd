class_name RangeOutline
extends Node2D

var tower_range: float
var color: Color
var is_valid_placement: bool

func _init() -> void:
	z_index = 3

func redraw(target_range, is_valid) -> void:
	tower_range = target_range
	is_valid_placement = is_valid
	color = Color(0.2, 0.0, 0.2, 0.5) if is_valid_placement else Color(1.0, 0.0, 0.0, 0.5)
	
	if tower_range > 0 and tower_range < 999999:
		queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, tower_range + 1.0, color, false, 2.0)
