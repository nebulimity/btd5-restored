extends Node2D

@onready var spawner = $Spawner
@onready var play_button = $SidePanel/PlayButton

var map_def: MonkeyLaneDef
var current_round: int = 1
var active_bloons: int = 0
var map_scene = preload("res://scenes/maps/monkey_lane.tscn")
var map = map_scene.instantiate()

func _ready():
	map_def = MonkeyLaneDef.new()
	map_def.parse_monkey_lane()
	
	spawner.setup(map_def)
	add_child(map)
	
	play_button.pressed.connect(_on_play_button_pressed)
	play_button.disabled = false
	
	spawner.child_entered_tree.connect(_on_bloon_spawned)

func _on_play_button_pressed():
	start_round(current_round)
	play_button.disabled = true
	play_button.visible = false
	play_button.get_node("Select").play()

func start_round(round_number: int):
	spawner.start_round(round_number - 1)

func _on_bloon_spawned(node: Node):
	if node is Bloon:
		active_bloons += 1
		node.bloon_removed.connect(_on_bloon_removed)

func _on_bloon_removed():
	active_bloons -= 1
	check_round_complete()

func _process(_delta: float) -> void:
	if not play_button.disabled:
		return
	
	check_round_complete()

func check_round_complete():
	if active_bloons == 0 and spawner.wave_set.current_wave != null and spawner.wave_set.current_wave.is_complete():
		play_button.disabled = false
		play_button.visible = true
		current_round += 1
