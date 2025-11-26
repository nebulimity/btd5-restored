class_name InGameMenu
extends Control

signal tower_purchase_requested(tower_type: String)
signal play_button_pressed
signal fast_forward_toggled(enabled: bool)

@onready var money_text: Label = $"../InGameMenu/SidePanel/UI/Money/Value"
@onready var lives_text: Label = $"../InGameMenu/SidePanel/UI/Lives/Value"
@onready var round_text: Label = $"../InGameMenu/BottomPanel/Default/RoundValue"
@onready var rbe_text: Label = $"../InGameMenu/BottomPanel/Default/RBEValue"
@onready var play_button: TextureButton = $"../InGameMenu/SidePanel/UI/PlayButton"
@onready var fast_forward_button: TextureButton = $"../InGameMenu/SidePanel/UI/FastForwardButton"

@onready var tower_buttons_container: GridContainer = $"../InGameMenu/SidePanel/UI/SmoothScrollContainer/MarginContainer/GridContainer"

func _ready() -> void:
	connect_tower_buttons()

func connect_tower_buttons() -> void:
	var tower_button_map = {
		"DartTower": "DartMonkey",
		"TackTower": "TackShooter",
		"SniperTower": "SniperMonkey",
		"BoomerangTower": "BoomerangThrower",
		"NinjaTower": "NinjaMonkey",
		"BombTower": "BombTower",
		"IceTower": "IceTower",
		"GlueTower": "GlueTower",
		"BuccaneerTower": "BuccaneerTower",
		"PlaneTower": "MonkeyAce",
		"SuperTower": "SuperMonkey",
		"ApprenticeTower": "MonkeyApprentice",
		"VillageTower": "MonkeyVillage",
		"BananaTower": "BananaTower",
		"MortarTower": "MortarTower",
		"DartlingTower": "DartlingGun",
		"SpikeTower": "SpikeFactory",
		"RoadSpikes": "RoadSpikes",
		"Pineapple": "ExplodingPineapple"
	}
	
	for button_name in tower_button_map:
		var button = tower_buttons_container.get_node_or_null(button_name)
		if button and button is BaseButton:
			var tower_type = tower_button_map[button_name]
			button.pressed.connect(_on_tower_button_pressed.bind(tower_type))

func _on_tower_button_pressed(tower_type: String) -> void:
	tower_purchase_requested.emit(tower_type)

func _on_play_button_pressed() -> void:
	play_button.get_node("Select").play()
	play_button_pressed.emit()

func _on_fast_forward_button_pressed() -> void:
	fast_forward_button.get_node("Select").play()
	var is_fast_forward = Engine.time_scale > 1.0
	fast_forward_toggled.emit(not is_fast_forward)
	update_fast_forward_button(not is_fast_forward)

func update_fast_forward_button(enabled: bool) -> void:
	var blue_arrows = fast_forward_button.get_node_or_null("BlueArrows")
	if blue_arrows:
		if enabled:
			blue_arrows.texture = blue_arrows.get_meta("pressed_texture")
			blue_arrows.material.set_shader_parameter("shadow_strength", 0.0)
		else:
			blue_arrows.texture = blue_arrows.get_meta("default_texture")
			blue_arrows.material.set_shader_parameter("shadow_strength", 0.25)

func set_play_button_enabled(enabled: bool) -> void:
	play_button.disabled = not enabled
	play_button.visible = enabled
	fast_forward_button.visible = not enabled

func update_money_display(value: int) -> void:
	if money_text:
		money_text.text = str(value)

func update_lives_display(value: int) -> void:
	if lives_text:
		lives_text.text = str(value)

func update_round_display(value: int) -> void:
	if round_text:
		round_text.text = "%s of 65" % [str(value)]

func update_rbe_display(value: int) -> void:
	if rbe_text:
		rbe_text.text = str(value)
