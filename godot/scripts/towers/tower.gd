class_name Tower
extends Node2D

@onready var place_sound = $"../Sounds/Place"

var tower_type: String
var tower_def: Dictionary
var current_range: float
var selected: bool
var orientation: float
var sprite: Sprite2D
var range_combo: Node2D

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	current_range = tower_def["range"]
	orientation = -90.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load(tower_def["sprite_path"])
	sprite.offset = tower_def["position_offset"]
	sprite.z_index = 2
	sprite.rotate(deg_to_rad(orientation))
	add_child(sprite)
	
	place_sound.play()
	
	if current_range > 0 and current_range < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)
		
func _process(_delta: float) -> void:
	range_combo.redraw(tower_def["range"], true)

func show_range() -> void:
	range_combo.visible = true

func hide_range() -> void:
	range_combo.visible = false

func highlight():
	sprite.modulate = Color(0.0, 1.0, 0.0)
	
func unhighlight():
	sprite.modulate = Color(1.0, 1.0, 1.0)
