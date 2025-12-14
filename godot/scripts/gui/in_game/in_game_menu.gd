class_name InGameMenu
extends Control

signal tower_purchase_requested(tower_type: String)
signal play_button_pressed
signal fast_forward_toggled(enabled: bool)

@onready var money_text: Label = $SidePanel/UI/Money/Value
@onready var lives_text: Label = $SidePanel/UI/Lives/Value
@onready var round_text: Label = $BottomPanel/Default/RoundValue
@onready var rbe_text: Label = $BottomPanel/Default/RBEValue
@onready var play_button: TextureButton = $SidePanel/UI/PlayButton
@onready var fast_forward_button: TextureButton = $SidePanel/UI/FastForwardButton
@onready var tower_buttons_container: GridContainer = $SidePanel/UI/SmoothScrollContainer/MarginContainer/GridContainer

@onready var sfx_button: TextureButton = $BottomPanel/Misc/Default/SfxButton
@onready var music_button: TextureButton = $BottomPanel/Misc/Default/MusicButton

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
	SoundManager.play("select")
	tower_purchase_requested.emit(tower_type)

func _on_play_button_pressed() -> void:
	SoundManager.play("select")
	play_button_pressed.emit()

func _on_fast_forward_button_pressed() -> void:
	SoundManager.play("select")
	var is_fast_forward = Engine.time_scale > 1.0
	fast_forward_toggled.emit(not is_fast_forward)
	update_fast_forward_button(not is_fast_forward)

func update_fast_forward_button(enabled: bool) -> void:
	var blue_arrows = fast_forward_button.get_node("BlueArrows")
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
	money_text.text = str(value)

func update_lives_display(value: int) -> void:
	lives_text.text = str(value)

func update_round_display(value: int) -> void:
	round_text.text = "%s of 65" % [str(value)]

func update_rbe_display(value: int) -> void:
	rbe_text.text = str(value)

func _on_sfx_button_pressed() -> void:
	if not SoundManager.sfx_muted:
		SoundManager.mute_sfx(true)
		sfx_button.texture_normal = sfx_button.get_meta("pressed_texture")
		sfx_button.texture_hover = sfx_button.get_meta("pressed_outlined")
	else:
		SoundManager.mute_sfx(false)
		sfx_button.texture_normal = sfx_button.get_meta("default_texture")
		sfx_button.texture_hover = sfx_button.get_meta("default_outlined")

func _on_music_button_pressed() -> void:
	if not SoundManager.music_muted:
		SoundManager.mute_music(true)
		music_button.texture_normal = music_button.get_meta("pressed_texture")
		music_button.texture_hover = music_button.get_meta("pressed_outlined")
	else:
		SoundManager.mute_music(false)
		music_button.texture_normal = music_button.get_meta("default_texture")
		music_button.texture_hover = music_button.get_meta("default_outlined")
