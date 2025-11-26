extends Node2D

@onready var spawner = $Spawner
@onready var in_game_menu = $InGameMenu

var money: int = 650
var lives: int = 150
var current_round: int = 1
var rbe: int = 0
var active_bloons: int = 0
var map_def: MonkeyLaneDef
var map_scene = preload("res://scenes/maps/monkey_lane.tscn")
var map = map_scene.instantiate()

var current_place_state: PlaceState = null
var placed_towers: Array[Tower] = []

var terrain_node: Node2D
var track_area: Area2D
var land_area: Area2D
var water_area: Area2D

func _ready():
	map_def = MonkeyLaneDef.new()
	map_def.parse_monkey_lane()
	
	spawner.setup(map_def)
	add_child(map)
	
	setup_terrain_areas()
	
	in_game_menu.play_button_pressed.connect(_on_play_button_pressed)
	in_game_menu.fast_forward_toggled.connect(_on_fast_forward_toggled)
	in_game_menu.tower_purchase_requested.connect(_on_tower_purchase_requested)
	
	update_ui()

func setup_terrain_areas():
	terrain_node = map.get_node_or_null("Terrain")
	track_area = terrain_node.get_node_or_null("Track")
	land_area = terrain_node.get_node_or_null("Land")
	water_area = terrain_node.get_node_or_null("Water")

func update_ui():
	in_game_menu.update_money_display(money)
	in_game_menu.update_lives_display(lives)
	in_game_menu.update_round_display(current_round)
	in_game_menu.update_rbe_display(rbe)

func _on_rbe_changed(new_rbe: int):
	rbe = new_rbe
	in_game_menu.update_rbe_display(rbe)

func _on_play_button_pressed():
	start_round(current_round)
	in_game_menu.set_play_button_enabled(false)

func start_round(round_number: int):
	spawner.start_round(round_number - 1)

func _on_bloon_spawned(node: Node):
	if node is Bloon:
		active_bloons += 1
		node.bloon_removed.connect(_on_bloon_removed)

func _on_bloon_removed():
	active_bloons -= 1
	check_round_complete()

func check_round_complete():
	if active_bloons == 0 and spawner.wave_set.current_wave != null and spawner.wave_set.current_wave.is_complete():
		in_game_menu.set_play_button_enabled(true)
		Engine.time_scale = 1.0
		current_round += 1
		in_game_menu.update_round_display(current_round)
		in_game_menu.update_fast_forward_button(false)

func _on_fast_forward_toggled(enabled: bool):
	Engine.time_scale = 3.0 if enabled else 1.0

func _on_tower_purchase_requested(tower_type: String):
	var tower_def = TowerFactory.get_tower_def(tower_type)
	
	if money < tower_def["cost"]:
		print("Cannot afford tower: need $", tower_def["cost"], " but have $", money)
		return
	
	if current_place_state:
		current_place_state.queue_free()
		current_place_state = null
	
	enter_placement_mode(tower_type)

func enter_placement_mode(tower_type: String):
	current_place_state = PlaceState.new()
	current_place_state.setup(tower_type)
	current_place_state.track_area = track_area
	current_place_state.land_area = land_area
	current_place_state.water_area = water_area
	
	current_place_state.placement_confirmed.connect(_on_tower_placed)
	current_place_state.placement_cancelled.connect(_on_placement_cancelled)
	
	add_child(current_place_state)

func _on_tower_placed(tower_type: String, pos: Vector2):
	var tower_def = TowerFactory.get_tower_def(tower_type)
	
	money -= tower_def["cost"]
	in_game_menu.update_money_display(money)
	
	var tower = Tower.new(tower_type)
	tower.global_position = pos
	placed_towers.append(tower)
	add_child(tower)
	
	current_place_state = null
	print("Placed ", tower_type, " at ", pos)

func _on_placement_cancelled():
	current_place_state = null
	print("Tower placement cancelled")
