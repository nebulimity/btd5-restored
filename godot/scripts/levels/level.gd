class_name Level
extends Node

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

var cash_multiplier: float = 1.0

var active_bloons: int = 0

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

var terrain_node: Node2D
var track_area: Area2D
var land_area: Area2D
var water_area: Area2D

@onready var spawner: Node = $"../Spawner"
@onready var in_game_menu: Control = $"../InGameMenu"

func _ready() -> void:
	map_scene = preload("res://scenes/maps/monkey_lane.tscn")
	map = map_scene.instantiate()
	
	collision_grid = CollisionGrid.new()
	add_child(collision_grid)
	
	map_def = MonkeyLaneDef.new()
	map_def.parse_monkey_lane()
	
	neutral_state = NeutralState.new()
	add_child(neutral_state)
	
	get_parent().add_child.call_deferred(map)
	
	spawner.setup(map_def)
	
	setup_terrain_areas()
	
	in_game_menu.play_button_pressed.connect(_on_play_button_pressed)
	in_game_menu.fast_forward_toggled.connect(_on_fast_forward_toggled)
	in_game_menu.tower_purchase_requested.connect(_on_tower_purchase_requested)
	
	call_deferred("update_ui")
	
	SoundManager.play_music("main_theme")

func update_ui():
	in_game_menu.update_money_display(money)
	in_game_menu.update_lives_display(lives)
	in_game_menu.update_round_display(current_round)
	in_game_menu.update_rbe_display(rbe)

func setup_terrain_areas():
	terrain_node = map.get_node_or_null("Terrain")
	if terrain_node:
		track_area = terrain_node.get_node_or_null("Track")
		land_area = terrain_node.get_node_or_null("Land")
		water_area = terrain_node.get_node_or_null("Water")

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
		node.bloon_popped.connect(_on_bloon_popped)

func _on_bloon_removed(bloon: Bloon = null):
	active_bloons -= 1
	if bloon and bloon in bloons:
		bloons.erase(bloon)
	check_round_complete()

func _on_bloon_popped(bloon: Bloon):
	var cash = bloon.get_pop_value()
	add_cash(int(cash))

func check_round_complete():
	if active_bloons == 0 and spawner.wave_set.current_wave != null and spawner.wave_set.current_wave.is_complete():
		var round_bonus = 100 + (current_round - 1)
		add_cash(round_bonus)

		in_game_menu.set_play_button_enabled(true)
		Engine.time_scale = 1.0
		current_round += 1
		in_game_menu.update_fast_forward_button(false)

func add_cash(amount: int) -> void:
	var final_amount = int(round(amount * cash_multiplier))
	money += final_amount

func _on_fast_forward_toggled(enabled: bool):
	Engine.time_scale = 3.0 if enabled else 1.0

func _on_tower_purchase_requested(tower_type: String):
	var tower_def = TowerFactory.get_tower_def(tower_type)
	
	if money < tower_def["cost"]:
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
	
	get_parent().add_child(current_place_state)

func _on_tower_placed(tower_type: String, pos: Vector2):
	var tower_def = TowerFactory.get_tower_def(tower_type)
	
	money -= tower_def["cost"]
	
	var tower = Tower.new(tower_type)
	tower.global_position = pos
	tower.level = self
	just_placed = true
	placed_towers.append(tower)
	update_selection(tower)
	get_parent().get_node("Towers").add_child(tower)
	
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
