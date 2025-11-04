extends Node2D

@onready var spawner = $Spawner
@onready var play_button = $SidePanel/UI/PlayButton
@onready var fast_forward_button = $SidePanel/UI/FastForwardButton
@onready var money_text = $SidePanel/UI/Money/Value
@onready var lives_text = $SidePanel/UI/Lives/Value
@onready var round_text = $BottomPanel/Default/RoundValue
@onready var rbe_text = $BottomPanel/Default/RBEValue
@onready var blue_arrows = $SidePanel/UI/FastForwardButton/BlueArrows

var money: int = 650:
	set(value):
		money = value
		money_text.text = str(money)

var lives: int = 150:
	set(value):
		lives = value
		lives_text.text = str(lives)

var current_round: int = 1:
	set(value):
		current_round = value
		round_text.text = "%s of 65" % [str(current_round)]
			
var rbe: int = 0:
	set(value):
		rbe = value
		rbe_text.text = str(rbe)

var active_bloons: int = 0
var fast_forward: bool = false
var map_def: MonkeyLaneDef
var map_scene: PackedScene = preload("res://scenes/maps/monkey_lane.tscn")
var map = map_scene.instantiate()

func _ready():
	map_def = MonkeyLaneDef.new()
	map_def.parse_monkey_lane()
	
	spawner.setup(map_def)
	add_child(map)
	
	update_ui()
	
func _on_rbe_changed(new_rbe: int):
	rbe = new_rbe

func _on_play_button_pressed():
	start_round(current_round)
	play_button.visible = false
	fast_forward_button.visible = true
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

func check_round_complete():
	if active_bloons == 0 and spawner.wave_set.current_wave != null and spawner.wave_set.current_wave.is_complete():
		fast_forward_button.visible = false
		play_button.visible = true
		if fast_forward:
			fast_forward = false
			Engine.time_scale = 1.0
			update_fast_forward_button()
		current_round += 1

func update_ui():
	money_text.text = str(money)
	lives_text.text = str(lives)
	round_text.text = "%s of 65" % [str(current_round)]
	rbe_text.text = str(rbe) if rbe != 0 else "-"
	
func update_fast_forward_button():
	if fast_forward:
		blue_arrows.texture = blue_arrows.get_meta("pressed_texture")
		blue_arrows.material.set_shader_parameter("shadow_strength", 0.0)
	else:
		blue_arrows.texture = blue_arrows.get_meta("default_texture")
		blue_arrows.material.set_shader_parameter("shadow_strength", 0.25)

func _on_fast_forward_button_pressed() -> void:
	fast_forward = not fast_forward
	fast_forward_button.get_node("Select").play()
	Engine.time_scale = 3.0 if fast_forward else 1.0
	update_fast_forward_button()
