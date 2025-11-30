class_name Tower
extends Node2D

@onready var place_sound: AudioStreamPlayer = $"../Sounds/Place"
@onready var select_sound: AudioStreamPlayer = $"../Sounds/Select"

var tower_type: String
var tower_def: Dictionary
var current_range: float
var selected: bool
var orientation: float
var sprite: Sprite2D
var outline: Sprite2D
var outline_shader: ShaderMaterial
var range_combo: Node2D
var level: Level

var weapons: Array[Weapon] = []
var weapon_offsets: Array[Vector2] = []
var targets_by_priority: Array[Bloon] = []
var current_target: Bloon = null
var target_priority: String = "first"  # first, last, close, strong

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	current_range = tower_def["range"]
	orientation = tower_def["rotation_offset"]
	
	setup_weapons()

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
	
	level = get_parent().get_node_or_null("Level")
	if not level:
		level = get_parent().get_parent().get_node_or_null("Level")

func setup_weapons() -> void:
	match tower_type:
		"DartMonkey":
			var proj_def = ProjectileDef.new("res://assets/projectiles/dart.svg")
			proj_def.Pierce(1).Damage(1).Speed(850)
			
			var weapon = Single.new()
			weapon.SetRange(161).SetReloadTime(0.9).SetPower(850).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		
		"TackShooter":
			var proj_def = ProjectileDef.new("res://assets/projectiles/tack.svg")
			proj_def.Pierce(1).Damage(1).Speed(200)
			
			var weapon = Circular.new()
			weapon.SetRange(70).SetReloadTime(1.66).SetPower(350).SetProjectile(proj_def)
			weapon.SetAngle(TAU).SetCount(8)
			weapons.append(weapon)
			weapon_offsets.append(Vector2.ZERO)
		
		"SuperMonkey":
			var proj_def = ProjectileDef.new("res://assets/projectiles/dart.svg")
			proj_def.Pierce(1).Damage(1).Speed(850)
			
			var weapon = Single.new()
			weapon.SetRange(500).SetReloadTime(0.058).SetPower(700).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		_:
			pass

func _process(delta: float) -> void:
	if not level:
		return
	
	range_combo.redraw(tower_def["range"], true)
	if outline.visible:
		outline.texture = sprite.texture
	
	for weapon in weapons:
		weapon.update(delta)
	
	find_targets()
	
	if weapons.size() > 0 and targets_by_priority.size() > 0:
		current_target = get_target_by_priority()
		
		for i in range(weapons.size()):
			var weapon = weapons[i]
			if weapon.can_fire():
				var offset = weapon_offsets[i] if i < weapon_offsets.size() else Vector2.ZERO
				weapon.execute(self, self, current_target, offset)

func find_targets() -> void:
	targets_by_priority.clear()
	
	if not level:
		return
	
	var bloons = level.get_bloons()
	for bloon in bloons:
		if not is_instance_valid(bloon): # hacky fix for child bloons that were leaked
			continue
			
		if bloon.bloon_type < 0:
			continue
		
		var dist = global_position.distance_to(bloon.global_position)
		if dist <= current_range:
			targets_by_priority.append(bloon)
	
	targets_by_priority.sort_custom(func(a, b): return a.overall_progress > b.overall_progress)

func get_target_by_priority() -> Bloon:
	if targets_by_priority.size() == 0:
		return null
	
	match target_priority:
		"first":
			return targets_by_priority[0]
		"last":
			return targets_by_priority[targets_by_priority.size() - 1]
		"close":
			var closest = targets_by_priority[0]
			var closest_dist = global_position.distance_to(closest.global_position)
			for bloon in targets_by_priority:
				var dist = global_position.distance_to(bloon.global_position)
				if dist < closest_dist:
					closest = bloon
					closest_dist = dist
			return closest
		"strong":
			var strongest = targets_by_priority[0]
			for bloon in targets_by_priority:
				if bloon.health > strongest.health:
					strongest = bloon
			return strongest
		_:
			return targets_by_priority[0]

func show_range() -> void:
	range_combo.visible = true

func hide_range() -> void:
	range_combo.visible = false

func highlight():
	outline.visible = true
	
func unhighlight():
	outline.visible = false

func select():
	selected = true
	if select_sound:
		select_sound.play()
	if range_combo:
		range_combo.visible = true

func deselect():
	selected = false
	range_combo.visible = false
