class_name Level
extends Node

@export var map_name: String = "monkey_lane"

var money: int = 650:
	set(value):
		money = value
		in_game_menu.update_money_display(money)

var lives: int = 150:
	set(value):
		lives = value
		in_game_menu.update_lives_display(lives)

var current_round: int = 1:
	set(value):
		current_round = value
		in_game_menu.update_round_display(current_round)

var rbe: int = 0:
	set(value):
		rbe = value
		in_game_menu.update_rbe_display(rbe)

var active_bloons: int = 0
var cash_multiplier: float = 1.0
var process_multiplier: int = 1
var bursts_this_process: int = 0

var map_def: MonkeyLaneDef
var map_scene: PackedScene
var map: Node

var neutral_state: NeutralState
var current_place_state: PlaceState
var placed_towers: Array[Tower] = []
var selected_tower: Node2D
var just_placed: bool

var projectiles: Array[Projectile] = []
var bloons: Array[Bloon] = []
var collision_grid: CollisionGrid
var time_accumulator: float = 0.0

var terrain_node: Node2D
var track_map: TerrainType
var land_map: TerrainType
var water_map: TerrainType
var towers_map: TerrainType

@onready var spawner: Node = $"../Spawner"
@onready var in_game_menu: Control = $"../InGameMenu"

func _ready() -> void:
	map_scene = preload("res://scenes/maps/monkey_lane.tscn")
	map = map_scene.instantiate()
	
	collision_grid = CollisionGrid.new(self)
	add_child(collision_grid)
	
	map_def = MonkeyLaneDef.new()
	map_def.parse_monkey_lane()
	
	neutral_state = NeutralState.new()
	add_child(neutral_state)
	
	get_parent().add_child.call_deferred(map)
	
	spawner.setup(map_def)
	
	setup_terrain_masks()
	
	in_game_menu.play_button_pressed.connect(_on_play_button_pressed)
	in_game_menu.fast_forward_toggled.connect(_on_fast_forward_toggled)
	in_game_menu.tower_purchase_requested.connect(_on_tower_purchase_requested)
	
	call_deferred("update_ui")
	
	AssetManager.preload_all()
	SoundManager.play_music("main_theme")
	TowerFactory.tower_factory()

func _process(delta: float) -> void:
	bursts_this_process = 0
	time_accumulator += TimeManager.delta
	
	var fixed_step = TimeManager.max_dt
	
	while time_accumulator >= fixed_step:
		InterpolationManager.save_previous_transforms()

		collision_grid.process(fixed_step)
		
		for bloon in bloons:
			if is_instance_valid(bloon):
				bloon.process(fixed_step)
		
		for tower in placed_towers:
			if is_instance_valid(tower):
				tower.process(fixed_step)
		
		for proj in projectiles:
			if is_instance_valid(proj):
				proj.process(fixed_step)
		
		get_tree().call_group("fixed_animators", "advance_time", fixed_step)
		
		time_accumulator -= fixed_step
	
	var fraction: float = time_accumulator / fixed_step
	InterpolationManager.interpolate_all(fraction)

func update_ui():
	in_game_menu.update_money_display(money)
	in_game_menu.update_lives_display(lives)
	in_game_menu.update_round_display(current_round)
	in_game_menu.update_rbe_display(rbe)

func setup_terrain_masks():
	track_map = TerrainType.new()
	land_map = TerrainType.new()
	water_map = TerrainType.new()
	towers_map = TerrainType.new()
	
	if not map.is_inside_tree():
		await map.tree_entered
		
	terrain_node = map.get_node_or_null("Terrain")
	if terrain_node:
		var track_sprite = terrain_node.get_node_or_null("Track") as Sprite2D
		var land_sprite = terrain_node.get_node_or_null("Land") as Sprite2D
		var water_sprite = terrain_node.get_node_or_null("Water") as Sprite2D
		
		if track_sprite and track_sprite.texture:
			var top_left = track_sprite.global_position + track_sprite.offset
			if track_sprite.centered:
				top_left -= (track_sprite.texture.get_size() * track_sprite.global_scale) / 2.0
			track_map.draw_to_map(track_sprite.texture, top_left, track_sprite.global_scale)
			
		if land_sprite and land_sprite.texture:
			var top_left = land_sprite.global_position + track_sprite.offset
			if land_sprite.centered:
				top_left -= (land_sprite.texture.get_size() * land_sprite.global_scale) / 2.0
			land_map.draw_to_map(land_sprite.texture, top_left, land_sprite.global_scale)
			
		if water_sprite and water_sprite.texture:
			var top_left = water_sprite.global_position + track_sprite.offset
			if water_sprite.centered:
				top_left -= (water_sprite.texture.get_size() * water_sprite.global_scale) / 2.0
			water_map.draw_to_map(water_sprite.texture, top_left, water_sprite.global_scale)

func _on_rbe_changed(new_rbe: int):
	rbe = new_rbe

func _on_play_button_pressed():
	start_round(current_round)
	in_game_menu.set_play_button_enabled(false)

func start_round(round_number: int):
	spawner.start_round(round_number - 1)

func _on_bloon_spawned(node: Node):
	if node is Bloon:
		active_bloons += 1
		bloons.append(node)
		node.bloon_removed.connect(_on_bloon_removed.bind(node))

func _on_bloon_removed(bloon: Bloon = null):
	active_bloons -= 1
	if bloon and bloon in bloons:
		bloons.erase(bloon)
	check_round_complete()

func check_round_complete():
	if active_bloons == 0 and spawner.wave_set.current_wave != null and spawner.wave_set.current_wave.is_complete():
		var round_bonus = 100 + (current_round - 1)
		add_cash(round_bonus)

		in_game_menu.set_play_button_enabled(true)
		TimeManager.time_scale = 1.0
		current_round += 1
		in_game_menu.update_fast_forward_button(false)

func add_cash(amount: int) -> void:
	var final_amount = int(round(amount * cash_multiplier))
	money += final_amount

func _on_fast_forward_toggled(enabled: bool):
	TimeManager.time_scale = 3.0 if enabled else 1.0

func _on_tower_purchase_requested(tower_type: String):
	var tower_def = TowerFactory.get_base_tower(tower_type)
	
	if money < tower_def.cost:
		return
	
	if current_place_state:
		current_place_state.queue_free()
		current_place_state = null
	
	enter_placement_mode(tower_type)

func enter_placement_mode(tower_type: String):
	current_place_state = PlaceState.new()
	
	current_place_state.track_map = track_map
	current_place_state.land_map = land_map
	current_place_state.water_map = water_map
	current_place_state.towers_map = towers_map
	
	current_place_state.setup(tower_type)
	
	current_place_state.placement_confirmed.connect(_on_tower_placed)
	current_place_state.placement_cancelled.connect(_on_placement_cancelled)
	
	get_parent().add_child(current_place_state)

func _on_tower_placed(tower_type: String, pos: Vector2):
	var tower_def: TowerDef = TowerFactory.get_base_tower(tower_type)
	money -= tower_def.cost
	
	var footprint_tex = load("res://assets/occupied_space/" + tower_def.occupied_space + ".svg")
	var true_size = footprint_tex.get_size()
		
	var offset = -(true_size / 2.0) 
	var top_left_pos = pos + offset
		
	towers_map.draw_to_map(footprint_tex, top_left_pos, Vector2.ONE)

	var tower = preload("res://scenes/entities/tower.tscn").instantiate() as Tower
	update_selection(tower)
	placed_towers.append(tower)
	get_parent().get_node("Towers").add_child(tower)
	tower.initialize(tower_type, pos, self)
	
	just_placed = true
	current_place_state = null

func _on_placement_cancelled():
	current_place_state = null

func update_selection(new_tower: Node2D) -> void:
	if selected_tower == new_tower and selected_tower != null and new_tower != null:
		SoundManager.play("select")
		return
	if selected_tower:
		selected_tower.deselect()
		selected_tower = null
	if new_tower:
		new_tower.select()
		selected_tower = new_tower
	else:
		selected_tower = null

func add_projectile(proj: Projectile) -> void:
	projectiles.append(proj)
	get_parent().add_child(proj)

func get_bloons() -> Array[Bloon]:
	return bloons
