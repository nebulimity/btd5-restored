class_name Tower
extends Node2D

@onready var place_sound = $"../Sounds/Place"

var tower_type: String
var tower_def: Dictionary
var current_range: float
var selected: bool
var orientation: float
var sprite: Sprite2D
var outline: Sprite2D
var outline_shader: ShaderMaterial
var range_combo: Node2D

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	current_range = tower_def["range"]
	orientation = 270.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load(tower_def["sprite_path"])
	sprite.offset = tower_def["position_offset"]
	sprite.z_index = 2
	sprite.rotation_degrees = orientation
	add_child(sprite)
	
	outline_shader = ShaderMaterial.new()
	outline_shader.shader = load("res://shaders/outline.gdshader")
	outline_shader.set_shader_parameter("cutout", true)
	outline = Sprite2D.new()
	outline.offset = sprite.offset
	outline.position = sprite.position
	outline.z_index = 100
	outline.z_as_relative = true
	outline.material = outline_shader
	outline.visible = false
	sprite.add_child(outline)
	
	place_sound.play()
	
	if current_range > 0 and current_range < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)

func _process(_delta: float) -> void:
	range_combo.redraw(tower_def["range"], true)
	if outline.visible:
		outline.texture = sprite.texture

func show_range() -> void:
	range_combo.visible = true

func hide_range() -> void:
	range_combo.visible = false

func highlight() -> void:
	outline.visible = true
	
func unhighlight() -> void:
	outline.visible = false

func select() -> void:
	selected = true
	#range_combo.visible = true
	print("selected")

func deselect() -> void:
	selected = false
	#range_combo.visible = false
	print("deselected")
