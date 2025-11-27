class_name PlaceState
extends Node2D

signal placement_confirmed(tower_type: String, pos: Vector2)
signal placement_cancelled

var tower_type: String
var tower_def: Dictionary
var preview_sprite: Sprite2D
var glow: ShaderMaterial
var range_combo: Node2D
var footprint_area: Area2D
var is_valid_placement: bool = false

var track_area: Area2D
var land_area: Area2D
var water_area: Area2D

func setup(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	_initialize_preview()

func _initialize_preview() -> void:
	preview_sprite = Sprite2D.new()
	preview_sprite.texture = load(tower_def["sprite_path"])
	preview_sprite.offset = tower_def["position_offset"]
	preview_sprite.z_index = 10
	preview_sprite.rotate(deg_to_rad(-90.0))
	
	glow = ShaderMaterial.new()
	glow.shader = load("res://shaders/glow.gdshader")
	glow.set_shader_parameter("glow_color", Color(0.0, 0.0, 0.0, 0.7))
	preview_sprite.material = glow
	
	add_child(preview_sprite)
	
	if tower_def["range"] > 0 and tower_def["range"] < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)
	
	footprint_area = Area2D.new()
	footprint_area.collision_layer = 0
	footprint_area.collision_mask = 2
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = tower_def["occupied_space_radius"]
	collision_shape.shape = circle
	footprint_area.add_child(collision_shape)
	add_child(footprint_area)
	
	set_process(true)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	update_placement_validity()
	range_combo.redraw(tower_def["range"], is_valid_placement)

func update_placement_validity() -> void:
	is_valid_placement = false
	
	var overlapping_areas = footprint_area.get_overlapping_areas()
	var touching_land = overlapping_areas.has(land_area)
	var touching_track = overlapping_areas.has(track_area)
	var touching_water = water_area and overlapping_areas.has(water_area)
		
	if tower_def.get("requires_track", false):
		if not touching_track:
			return
		is_valid_placement = true
		return
	
	if tower_def.get("requires_water", false):
		if not touching_water:
			return
		is_valid_placement = true
		return
	
	if touching_land or touching_track or touching_water:
		return
	
	is_valid_placement = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_valid_placement:
				placement_confirmed.emit(tower_type, global_position)
				queue_free()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			placement_cancelled.emit()
			queue_free()
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			placement_cancelled.emit()
			queue_free()
