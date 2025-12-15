class_name Tower
extends Node2D

var tower_type: String
var tower_def: Dictionary
var current_range: float
var selected: bool
var orientation: float
var sprite: AnimatedSprite2D
var outline: Sprite2D
var outline_shader: ShaderMaterial
var range_combo: Node2D
var level: Level

var weapons: Array[Weapon] = []
var weapon_offsets: Array[Vector2] = []
var targets_by_priority: Array[Bloon] = []
var current_target: Bloon = null
var target_priority: String = "first"  # first, last, close, strong

var in_throw_animation: bool = false
var has_fired: bool = false
var behaviors: Array = [] 

var fire_weapon: Weapon = null
var fire_offset: Vector2 = Vector2.ZERO

var target_search_timer: float = 0.0

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_tower_def(type)
	current_range = tower_def["range"]
	orientation = tower_def["rotation_offset"]
	
	setup_weapons()
	
	if tower_def.get("rotates", true):
		behaviors.append(RotateToTarget.new())

func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.offset = tower_def.get("position_offset", Vector2.ZERO)
	sprite.z_index = 2
	sprite.rotation_degrees = orientation
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", false)
	sprite_frames.set_animation_speed("default", 30.0)
	
	var base_path = tower_def["sprite_path"].get_base_dir()
	var frame_index = 1
	
	while true:
		var frame_path = base_path + "/" + str(frame_index) + ".svg"
		if ResourceLoader.exists(frame_path):
			var texture = load(frame_path)
			sprite_frames.add_frame("default", texture)
			frame_index += 1
		else:
			break
	
	sprite.sprite_frames = sprite_frames
	sprite.animation_finished.connect(_on_animation_finished)
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
	
	if current_range > 0 and current_range < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)
	
	level = get_parent().get_node_or_null("Level")
	if not level:
		level = get_parent().get_parent().get_node_or_null("Level")
	
	SoundManager.play("place")

func setup_weapons() -> void:
	match tower_type:
		"DartMonkey":
			var damage_def = DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var proj_def = ProjectileDef.new("res://assets/projectiles/dart.svg")
			proj_def.Pierce(1).Speed(850).DamageEffect(damage_def)
			
			var weapon = Single.new()
			weapon.SetRange(161).SetReloadTime(0.9).SetPower(850).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		
		"TackShooter":
			var damage_def = DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var proj_def = ProjectileDef.new("res://assets/projectiles/tack.svg")
			proj_def.Pierce(1).Speed(200).DamageEffect(damage_def)
			
			var weapon = Circular.new()
			weapon.SetRange(70).SetReloadTime(1.66).SetPower(350).SetProjectile(proj_def)
			weapon.SetAngle(TAU).SetCount(8)
			weapons.append(weapon)
			weapon_offsets.append(Vector2.ZERO)
		
		"SniperMonkey":
			var damage_def = DamageEffectDef.new().Damage(2).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var proj_def = ProjectileDef.new("res://assets/projectiles/tack.svg")
			proj_def.Pierce(1).Speed(200).DamageEffect(damage_def)
			
			var weapon = Instant.new()
			weapon.SetReloadTime(2.2).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(Vector2.ZERO)
		
		"BoomerangThrower":
			var path_behavior = FollowPath.new().Path([
				CubicBezierDef.new().A(Vector2.ZERO).B(Vector2.ZERO).C(Vector2(112, 55)).D(Vector2(131, -27)),
				CubicBezierDef.new().A(Vector2(131, -27)).B(Vector2(151, -109)).C(Vector2(45, -159)).D(Vector2(-13, -11))
			])
			var damage_def = DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var behavior_def = BehaviorDef.new().Process(path_behavior)
			
			var proj_def = ProjectileDef.new("res://assets/projectiles/boomerang.svg")
			proj_def.Pierce(3).Radius(10).Speed(850)
			proj_def.DamageEffect(damage_def).Behavior(behavior_def)
			
			var weapon = Spread.new()
			weapon.SetRange(520).SetPower(700).SetReloadTime(1.33).SetProjectile(proj_def).SetCount(1).SetAngle(0.5)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		
		"NinjaMonkey":
			var damage_def = DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var proj_def = ProjectileDef.new("res://assets/projectiles/shuriken.svg")
			proj_def.Pierce(2).Radius(4).DamageEffect(damage_def)
			
			var weapon = Single.new()
			weapon.SetRange(360).SetReloadTime(0.6).SetPower(360).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		
		"SuperMonkey":
			var damage_def = DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)
			var proj_def = ProjectileDef.new("res://assets/projectiles/dart.svg")
			proj_def.Pierce(1).Speed(850).DamageEffect(damage_def)
			
			var weapon = Single.new()
			weapon.SetRange(500).SetReloadTime(0.058).SetPower(700).SetProjectile(proj_def)
			weapons.append(weapon)
			weapon_offsets.append(TowerFactory.get_tower_def(tower_type)["weapon_offset"])
		_:
			pass

func process(delta: float) -> void:
	target_search_timer += delta
	
	find_targets()
	
	for behavior in behaviors:
		if behavior.has_method("process"):
			behavior.process(self, delta)
	
	for weapon in weapons:
		weapon.update(delta)
	
	if fire_weapon != null and not has_fired and not in_throw_animation:
		fire()
	
	ready_fire()      
	check_fire_frame()
	
	if range_combo and selected:
		range_combo.redraw(tower_def["range"], true)
	if outline.visible and sprite.sprite_frames.get_frame_count("default") > 0:
		outline.texture = sprite.sprite_frames.get_frame_texture("default", sprite.frame)

func ready_fire() -> void:
	if in_throw_animation:
		return
	
	for i in range(weapons.size()):
		var weapon = weapons[i]
		
		if i == 0:
			var target_invalid = false
			
			if current_target == null or not is_instance_valid(current_target):
				target_invalid = true
			elif current_target.is_in_tunnel():
				target_invalid = true
			elif current_target.bloon_type == -1:
				target_invalid = true
			elif target_search_timer > 0.5:
				target_invalid = true
			elif global_position.distance_to(current_target.global_position) > current_range:
				target_invalid = true
			
			if target_invalid:
				current_target = null
				if targets_by_priority.size() > 0:
					current_target = get_target_by_priority()
				target_search_timer = 0.0
		
		if current_target == null:
			continue
		
		if weapon.can_fire():
			weapon.reset_cooldown()
			fire_weapon = weapon
			fire_offset = weapon_offsets[i] if i < weapon_offsets.size() else Vector2.ZERO
			
			in_throw_animation = true
			has_fired = false
			
			sprite.frame = 0
			sprite.play("default")

func check_fire_frame() -> void:
	if in_throw_animation and not has_fired:
		var trigger_frame = int(tower_def.get("fire_frame", 1))
		if sprite.frame >= trigger_frame - 1:
			fire()

func fire() -> void:
	if fire_weapon:
		has_fired = true
		if current_target:
			fire_weapon.execute(self, self, current_target, fire_offset)
		else:
			fire_weapon.execute(self, self, null, fire_offset)

func _on_animation_finished() -> void:
	in_throw_animation = false
	if tower_def.get("idle_frame"):
		sprite.frame = tower_def["idle_frame"] - 1

func find_targets() -> void:
	targets_by_priority.clear()
	
	if not level or not level.collision_grid:
		return
	
	var candidates = level.collision_grid.get_bloons_in_range(global_position, current_range)
	
	for bloon in candidates:
		if not is_instance_valid(bloon) or bloon.bloon_type == -1:
			continue
		
		if bloon.is_in_tunnel():
			continue
		
		var dist = global_position.distance_to(bloon.global_position)
		if dist <= current_range:
			targets_by_priority.append(bloon)
	
	if targets_by_priority.size() > 1:
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
				if bloon.get_total_rbe() > strongest.get_total_rbe():
					strongest = bloon
				elif bloon.get_total_rbe() == strongest.get_total_rbe() and bloon.overall_progress > strongest.overall_progress:
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
	SoundManager.play("select")
	if range_combo:
		range_combo.visible = true

func deselect():
	selected = false
	range_combo.visible = false
