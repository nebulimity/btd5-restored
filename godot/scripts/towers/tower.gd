class_name Tower
extends Node2D

var tower_type: String
var tower_def: TowerDef
var current_range: float
var selected: bool
var orientation: float
var sprite: AnimatedSprite2D
var outline: Sprite2D
var outline_shader: ShaderMaterial
var range_combo: Node2D
var level: Level

var targets_by_priority: Array[Bloon] = []
var current_target: Bloon = null
var target_priority: String = "first"  # first, last, close, strong

var in_throw_animation: bool = false
var has_fired: bool = false

var fire_weapon: Weapon = null

var target_search_timer: float = 0.0

func _init(type: String) -> void:
	tower_type = type
	tower_def = TowerFactory.get_base_tower(tower_type)
	current_range = tower_def.range_of_visibility
	orientation = tower_def.rotation_offset

func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.offset = tower_def.position_offset
	sprite.z_index = 2
	sprite.rotation_degrees = orientation
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", false)
	sprite_frames.set_animation_speed("default", 30.0)
	
	for texture in AssetManager.grab(tower_def.display):
		sprite_frames.add_frame("default", texture)
	
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

func process(delta: float) -> void:
	target_search_timer += delta
	
	find_targets()
	
	if tower_def.behavior and tower_def.behavior.process_behavior:
		tower_def.behavior.process_behavior.execute(self, delta)
	
	for weapon in tower_def.weapons:
		weapon.update(delta)
	
	if fire_weapon != null and not has_fired and not in_throw_animation:
		fire(0)
	
	ready_fire()      
	check_fire_frame()
	
	if range_combo and selected:
		range_combo.redraw(tower_def.range_of_visibility, true)
	if outline.visible and sprite.sprite_frames.get_frame_count("default") > 0:
		outline.texture = sprite.sprite_frames.get_frame_texture("default", sprite.frame)

func ready_fire() -> void:
	if in_throw_animation:
		return
	
	var i: int = 0
	for weapon in tower_def.weapons:
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
			
			in_throw_animation = true
			has_fired = false
			
			sprite.frame = 0
			sprite.play("default")
		
		i += 1

func check_fire_frame() -> void:
	if in_throw_animation and not has_fired:
		var trigger_frame = tower_def.fire_frame
		if sprite.frame >= trigger_frame - 1:
			fire(0)

func fire(index: int) -> void:
	var weapon = tower_def.weapons[index]
	
	if fire_weapon:
		has_fired = true
		if not current_target:
			current_target = null
		
		if tower_def.weapon_offsets and tower_def.weapon_offsets.size() > index and tower_def.weapon_offsets[index]:
			weapon.execute(self, self, current_target, tower_def.weapon_offsets[index])
		else:
			weapon.execute(self, self, current_target)

func _on_animation_finished() -> void:
	in_throw_animation = false
	if tower_def.idle_frame != -1:
		sprite.frame = tower_def.idle_frame - 1

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
