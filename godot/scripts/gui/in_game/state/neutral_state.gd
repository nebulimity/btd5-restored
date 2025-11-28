class_name NeutralState
extends Node2D

const HIGHLIGHT_RADIUS: float = 50.0

var mouse_pos: Vector2 = Vector2(-1, -1)
var last_mouse: Vector2 = Vector2(-1, -1)
var highlighted_tower: Node2D = null

@onready var level: Level = get_parent()

func _process(_delta: float) -> void:
	if level.current_place_state != null:
		return
		
	mouse_pos = get_global_mouse_position()

	if mouse_pos == last_mouse:
		return
	last_mouse = mouse_pos

	var closest_tower: Node2D = null
	var closest_dist: float = HIGHLIGHT_RADIUS
	for tower in level.placed_towers:
		var dist = tower.global_position.distance_to(mouse_pos)
		if dist <= closest_dist:
			closest_dist = dist
			closest_tower = tower

	if closest_tower != highlighted_tower:
		if highlighted_tower != null:
			highlighted_tower.unhighlight()
		if closest_tower != null:
			closest_tower.highlight()
		highlighted_tower = closest_tower
		
	if highlighted_tower:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if level.current_place_state != null:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if highlighted_tower:
				level.selected_tower = highlighted_tower
			elif level.selected_tower != null:
				level.selected_tower = null
