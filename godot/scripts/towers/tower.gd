class_name Tower
extends Node2D

const TARGET_FIRST: int = 0
const TARGET_LAST: int = 1
const TARGET_STRONG: int = 2
const TARGET_CLOSE: int = 3

var tower_type: String
var tower_def: TowerDef
var current_range: float
var selected: bool
var orientation: float
var range_combo: Node2D
var level: Level
var root_id: String = ""

var targets_by_priority: Array[Bloon] = []
var current_target: Bloon = null
var target_priority: int = TARGET_FIRST
var target_mask: int = 0
var collision_test_cells: Array = []

var in_throw_animation: bool = false
var has_fired: bool = false

var reload_timers: Array[CustomTimer] = []
var addon_clips: Array[FixedAnimatedSprite2D] = []

var throw_sequence: int = 0 

var target_search_timer: float = 0.0

@onready var visuals: Node2D = $Visuals
@onready var sprite: FixedAnimatedSprite2D = $Visuals/FixedAnimatedSprite2D
@onready var outline: Sprite2D = $Visuals/FixedAnimatedSprite2D/Outline

func initialize(type: String, pos: Vector2, lvl: Level) -> void:
	tower_type = type
	global_position = pos
	level = lvl
	tower_def = TowerFactory.get_base_tower(tower_type)
	current_range = tower_def.range_of_visibility
	orientation = tower_def.rotation_offset
	
	sprite.offset = tower_def.position_offset
	sprite.rotation_degrees = orientation
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", false)
	sprite_frames.set_animation_speed("default", 30.0)
	
	for texture in AssetManager.grab(tower_def.display):
		sprite_frames.add_frame("default", texture)
	
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.sprite_frames = sprite_frames
	
	addon_clips.clear()
	if tower_def.display_addons:
		for clip in tower_def.display_addons:
			var addon = FixedAnimatedSprite2D.new()
			addon.offset = clip.offset
			addon.centered = clip.centered
			addon.z_index = clip.z
			
			var addon_frames = SpriteFrames.new()
			addon_frames.remove_animation("default")
			addon_frames.add_animation("default")
			addon_frames.set_animation_loop("default", clip.loop)
			addon_frames.set_animation_speed("default", 30.0)
			
			for texture in AssetManager.grab(clip.clip):
				addon_frames.add_frame("default", texture)
			
			addon.sprite_frames = addon_frames
			sprite.add_child(addon)
			addon_clips.append(addon)
			
			if clip.loop:
				addon.play("default")
	
	outline.offset = sprite.offset
	outline.position = sprite.position
	
	if current_range > 0 and current_range < 999999:
		range_combo = RangeCombo.new()
		add_child(range_combo)
		range_combo.redraw(current_range, true)
	
	level = get_parent().get_node_or_null("Level")
	if not level:
		level = get_parent().get_parent().get_node_or_null("Level")
	
	if tower_def.target_mask:
		for mask in tower_def.target_mask:
			target_mask |= mask
	
	SoundManager.play("place")
	
	reload_timers.clear()
	for weapon in tower_def.weapons:
		var timer = CustomTimer.new(weapon.reload_time)
		reload_timers.append(timer)
	
	#InterpolationManager.register(self)
	level.collision_grid.register_tower(self)

func process(delta: float) -> void:
	target_search_timer += delta
	
	for timer in reload_timers:
		timer.process(delta)
	
	find_targets()
	
	if tower_def.behavior and tower_def.behavior.process_behavior:
		tower_def.behavior.process_behavior.execute(self, delta)
	
	ready_fire()      
	check_fire_frame()
	
	if range_combo and selected:
		range_combo.redraw(tower_def.range_of_visibility, true)
	if outline.visible and sprite.sprite_frames.get_frame_count("default") > 0:
		outline.texture = sprite.sprite_frames.get_frame_texture("default", sprite.frame)

func is_target_valid(bloon: Bloon) -> bool:
	if bloon == null or not is_instance_valid(bloon):
		return false
	if bloon.bloon_type == -1:
		return false
	if bloon.is_in_tunnel():
		return false
	
	var dist = global_position.distance_to(bloon.global_position)
	if dist > current_range + bloon.target_addon:
		return false
		
	if (bloon.immunity & target_mask) != 0:
		return false
		
	return true

func ready_fire() -> void:
	if tower_def.weapons == null:
		return
	
	if level.active_bloons == 0:
		return

	var target_found_this_frame: bool = false
	
	for i in range(tower_def.weapons.size()):
		var _weapon = tower_def.weapons[i]
		var timer = reload_timers[i]
		
		if not timer.running:
			var needs_target = true
			
			if not target_found_this_frame and needs_target:
				var target_invalid = false
				
				if current_target == null or target_search_timer > 0.5:
					target_invalid = true
				elif not is_target_valid(current_target):
					target_invalid = true
				
				if target_invalid:
					current_target = null
					
					if targets_by_priority.size() > 0:
						current_target = targets_by_priority.back()
						target_found_this_frame = true
						target_search_timer = 0.0
			
			if current_target != null or not needs_target:
				if i == 0:
					if in_throw_animation:
						pass
					else:
						sprite.frame = 0
						sprite.play("default")
						in_throw_animation = true
						has_fired = false
						
						if tower_def.fire_frame == -1:
							fire(i)
				else:
					fire(i)
				
				timer.reset()

func check_fire_frame() -> void:
	if in_throw_animation and not has_fired:
		var trigger_frame = tower_def.fire_frame
		if sprite.frame >= trigger_frame - 1:
			fire(0)

func fire(index: int) -> void:
	var weapon = tower_def.weapons[index]
	var valid_target = current_target if is_instance_valid(current_target) else null
	
	if tower_def.weapon_offsets and tower_def.weapon_offsets.size() > index and tower_def.weapon_offsets[index]:
		weapon.execute(self, self, valid_target, tower_def.weapon_offsets[index])
	else:
		weapon.execute(self, self, valid_target)
		
	has_fired = true

func _on_animation_finished() -> void:
	in_throw_animation = false
	if tower_def.idle_frame != -1:
		sprite.frame = tower_def.idle_frame - 1

func find_targets() -> void:
	targets_by_priority.clear()
	
	if not level or not level.collision_grid:
		return
	
	level.collision_grid.update_tower_targets(self)

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
		range_combo.redraw(tower_def.range_of_visibility, true)

func deselect():
	selected = false
	range_combo.visible = false

func _exit_tree() -> void:
	level.collision_grid.deregister_tower(self)
