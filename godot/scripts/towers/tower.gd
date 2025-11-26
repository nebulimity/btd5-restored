class_name Tower
extends Node2D

var tower_type: String
var tower_def: Dictionary
var current_range: float
var sprite: Sprite2D
var range_circle: Node2D

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	current_range = tower_def.get("range", 0)

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load(tower_def["sprite_path"])
	add_child(sprite)
	
	if current_range > 0 and current_range < 999999:
		range_circle = Node2D.new()
		range_circle.visible = false
		add_child(range_circle)
		range_circle.queue_redraw()

func show_range() -> void:
	if range_circle:
		range_circle.visible = true

func hide_range() -> void:
	if range_circle:
		range_circle.visible = false
