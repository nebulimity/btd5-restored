class_name PlaceState
extends Node2D

signal placement_confirmed(tower_type: String, pos: Vector2)
signal placement_cancelled

var tower_type: String
var tower_def: TowerDef
var preview_sprite: Sprite2D
var glow: ShaderMaterial
var range_combo: Node2D

var is_valid_placement: bool = false
var _last_valid_state: bool = false

var track_map: TerrainType
var land_map: TerrainType
var water_map: TerrainType
var towers_map: TerrainType

var candidate_footprint_img: Image
var footprint_offset: Vector2 

func setup(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_base_tower(tower_type)
	_initialize_preview()
	_initialize_footprint()

func _initialize_preview() -> void:
	preview_sprite = Sprite2D.new()
	preview_sprite.texture = AssetManager.grab(tower_type)[0]
	preview_sprite.offset = tower_def.position_offset
	preview_sprite.z_index = 10
	preview_sprite.rotate(deg_to_rad(tower_def.rotation_offset))
	
	glow = ShaderMaterial.new()
	glow.shader = preload("res://shaders/glow.gdshader")
	glow.set_shader_parameter("glow_color", Color(0.0, 0.0, 0.0, 0.7))
	preview_sprite.material = glow
	
	add_child(preview_sprite)
	
	if tower_def.range_of_visibility > 0 and tower_def.range_of_visibility < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)
	
	set_process(true)
	
func _initialize_footprint() -> void:
	var footprint_tex = load("res://assets/occupied_space/" + tower_def.occupied_space + ".svg")
	var true_size = footprint_tex.get_size()
	
	footprint_offset = -(true_size / 2.0)
	
	candidate_footprint_img = footprint_tex.get_image()
	var sw = ceili(true_size.x * TerrainType.STANDARD_PRECISION_SCALE)
	var sh = ceili(true_size.y * TerrainType.STANDARD_PRECISION_SCALE)
	candidate_footprint_img.resize(sw, sh, Image.INTERPOLATE_BILINEAR)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	update_placement_validity()
	
	if is_valid_placement != _last_valid_state:
		range_combo.redraw(tower_def.range_of_visibility, is_valid_placement)
		_last_valid_state = is_valid_placement

func update_placement_validity() -> void:
	var pos = global_position
	
	var top_left_pos = pos + footprint_offset
	
	var tex_size = candidate_footprint_img.get_size() / TerrainType.STANDARD_PRECISION_SCALE
	var left_edge = top_left_pos.x
	var top_edge = top_left_pos.y
	var right_edge = left_edge + tex_size.x
	var bottom_edge = top_edge + tex_size.y
	
	if left_edge < 0 or top_edge < 0 or right_edge > TerrainType.PLAY_AREA_WIDTH or bottom_edge > TerrainType.PLAY_AREA_HEIGHT:
		is_valid_placement = false
		return
	
	if tower_def.requires_track:
		var on_track = track_map.is_within(candidate_footprint_img, top_left_pos)
		var outside_land = land_map.is_outside(candidate_footprint_img, top_left_pos)
		is_valid_placement = on_track and outside_land
		return
	
	if tower_def.requires_water:
		is_valid_placement = water_map.is_within(candidate_footprint_img, top_left_pos)
		return
		
	var outside_track = track_map.is_outside(candidate_footprint_img, top_left_pos)
	var outside_water = water_map.is_outside(candidate_footprint_img, top_left_pos)
	var outside_land = land_map.is_outside(candidate_footprint_img, top_left_pos)
	var outside_towers = towers_map.is_outside(candidate_footprint_img, top_left_pos)
	
	is_valid_placement = outside_track and outside_water and outside_land and outside_towers
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_valid_placement:
				placement_confirmed.emit(tower_type, global_position)
				queue_free()
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			placement_cancelled.emit()
			queue_free()
