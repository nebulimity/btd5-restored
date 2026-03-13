class_name Bloon
extends Node2D

enum BloonType {
	INVALID = -1,
	RED = 0,
	BLUE = 1,
	GREEN = 2,
	YELLOW = 3,
	PINK = 4,
	BLACK = 5,
	WHITE = 6,
	LEAD = 7,
	ZEBRA = 8,
	RAINBOW = 9,
	CERAMIC = 10,
	MOAB = 11,
	BFB = 12,
	BOSS = 13
}

enum BloonImmunity {
	IMMUNITY_NONE = 0,
	IMMUNITY_NO_DETECTION = 1,
	IMMUNITY_ICE = 2,
	IMMUNITY_GLUE = 4,
	IMMUNITY_SPLOSION = 8,
	IMMUNITY_WIND = 16,
	IMMUNITY_LEAD = 32,
	IMMUNITY_MOAB = 64,
	IMMUNITY_BFB = 128,
	IMMUNITY_ZOMG = 256,
	IMMUNITY_ALL = 65535,
}

static var speed_multiplier_by_type = [
	1.0,    # RED
	1.4,    # BLUE
	1.8,    # GREEN
	3.2,    # YELLOW
	3.5,    # PINK
	1.8,    # BLACK
	2.0,    # WHITE
	1.0,    # LEAD
	1.8,    # ZEBRA
	2.2,    # RAINBOW
	2.5,    # CERAMIC
	1.0,    # MOAB
	0.25,   # BFB
	0.18    # BOSS (ZOMG)
]

static var rbe_by_type = [
	1,      # RED
	2,      # BLUE
	3,      # GREEN
	4,      # YELLOW
	5,      # PINK
	11,     # BLACK
	11,     # WHITE
	23,     # LEAD
	23,     # ZEBRA
	47,     # RAINBOW
	104,    # CERAMIC
	616,    # MOAB
	3164,   # BFB
	16656   # BOSS (ZOMG)
]

static var health_by_type = [
	1,      # RED
	1,      # BLUE
	1,      # GREEN
	1,      # YELLOW
	1,      # PINK
	1,      # BLACK
	1,      # WHITE
	1,      # LEAD
	1,      # ZEBRA
	1,      # RAINBOW
	10,     # CERAMIC
	200,    # MOAB
	700,    # BFB
	4000    # BOSS (ZOMG)
]

static var child_count_by_type = [
	1,      # RED
	1,      # BLUE
	1,      # GREEN
	1,      # YELLOW
	1,      # PINK
	2,      # BLACK
	2,      # WHITE
	2,      # LEAD
	2,      # ZEBRA
	2,      # RAINBOW
	2,      # CERAMIC
	4,      # MOAB
	4,      # BFB
	4       # BOSS (ZOMG)
]

static var spawn_order_offsets = [
	1,    # RED
	1,    # BLUE
	1,    # GREEN
	1,    # YELLOW
	1,    # PINK
	2,    # BLACK
	2,    # WHITE
	4,    # LEAD
	4,    # ZEBRA
	8,    # RAINBOW
	16,   # CERAMIC
	64,   # MOAB
	256,  # BFB
	1024  # BOSS (ZOMG)
]

static var base_immunities_by_type = [
	BloonImmunity.IMMUNITY_NONE,                                                             # RED
	BloonImmunity.IMMUNITY_NONE,                                                             # BLUE
	BloonImmunity.IMMUNITY_NONE,                                                             # GREEN
	BloonImmunity.IMMUNITY_NONE,                                                             # YELLOW
	BloonImmunity.IMMUNITY_NONE,                                                             # PINK
	BloonImmunity.IMMUNITY_SPLOSION,                                                         # BLACK
	BloonImmunity.IMMUNITY_ICE,                                                              # WHITE
	BloonImmunity.IMMUNITY_LEAD,                                                             # LEAD
	BloonImmunity.IMMUNITY_ICE | BloonImmunity.IMMUNITY_SPLOSION,                            # ZEBRA
	BloonImmunity.IMMUNITY_NONE,                                                             # RAINBOW
	BloonImmunity.IMMUNITY_NONE,                                                             # CERAMIC
	BloonImmunity.IMMUNITY_GLUE | BloonImmunity.IMMUNITY_ICE | BloonImmunity.IMMUNITY_MOAB,  # MOAB
	BloonImmunity.IMMUNITY_GLUE | BloonImmunity.IMMUNITY_ICE | BloonImmunity.IMMUNITY_BFB,   # BFB
	BloonImmunity.IMMUNITY_GLUE | BloonImmunity.IMMUNITY_ICE | BloonImmunity.IMMUNITY_ZOMG,  # BOSS (ZOMG)
]

static var max_radius: float = 10.0

static var cash_multiplier: float = 1.0
var cash_awarded: Array[bool] = []

var tile: Tile = null
var progress_step: float = 0.0
var tile_progress: float = 0.0
var overall_progress: float = 0.0
var collision_cell_index: int = -1

var is_in_general_vision: bool = false
var is_in_camo_vision: bool = false

var bloon_type: BloonType = BloonType.RED
var immunity: int = 0
var target_addon: float = 0.0
var health: int = 1
var max_health: int = 1
var is_camo: bool = false
var is_regen: bool = false
var regen_ceiling: int = 0
var regen_countdown: float = 0.0
var regen_interval: float = 3.0
var was_white: bool = false
var spawn_order_index: int = 0

const BASE_SPEED: float = 70.0
static var difficulty_speed_modifier: float = 0.0

var speed_modifier: float = 1.0
var iced: bool = false
var glued: bool = false
var stunned: bool = false

var ice_countdown: float = 0.0
var permaFrostSpeedScale: float = 1.0
var viralIce: bool = false
var viralDepth: int = 0
var iceShards: bool = false
var freezeLayers: int = 1
var arcticWind: float = 1.0
var arcticWindCountdown: int = 0
var iced_by = null

var glue_effect_def: GlueEffectDef = null
var glue_countdown: float = 0.0
var glueCorrosionInterval: float = 0.0
var glueCorrosionCountDown: float = 0.0
var glue_speed_scale: float = 1.0
var glue_soak: bool = false
var glueCash: float = 1.0
var glue_tower = null

var stunInherited: bool = false
var stunCountDown: float = 0.0

var burning: bool = false
var burnCountDown: float = 0.0
var burnInterval: float = 0.0
var burnLifeSpan: float = 0.0
var burnCash: float = 0.0

var parentIDs: Array = []

var level: Level = null
var sounds: Node = null
var radius: float = 10.0

static var global_spawn_counter: int = 0

var spawn_time: float = 0.0
var was_regenerated: bool = false
var special_flag: bool = false

var visuals: Node2D = null
var sprite: Sprite2D = null
var camo_effect: Sprite2D = null
var ice_effect: Sprite2D = null
var glue_effect: Sprite2D = null

signal bloon_removed
signal bloon_popped
static var next_id: int = 0
var id: int = 0

func initialize(p_type: BloonType, start_tile: Tile, start_progress: float = 0.0, p_is_regen: bool = false, p_is_camo: bool = false, p_spawn_order: int = 0, _p_level: Level = null):
	id = Bloon.next_id
	Bloon.next_id += 1
	
	spawn_time = p_spawn_order
	overall_progress = 0.0
	was_regenerated = false
	special_flag = false
	was_white = false
	parentIDs.clear()
	
	reset_status_effects()
	
	tile = start_tile
	tile_progress = start_progress
	
	is_camo = p_is_camo
	is_regen = p_is_regen
	regen_ceiling = p_type
	spawn_order_index = p_spawn_order
	
	level = _p_level
	
	if visuals == null:
		visuals = get_node("Visuals")
	if sprite == null:
		sprite = get_node("Visuals/Sprite2D")
	if camo_effect == null:
		camo_effect = get_node("Visuals/CamoEffect")
	if ice_effect == null:
		ice_effect = get_node("Visuals/IceEffect")
	if glue_effect == null:
		glue_effect = get_node("Visuals/GlueEffect")
	
	if tile:
		tile.update_bloon_position(self)
		update_layer_order()
	
	collision_cell_index = level.collision_grid.get_cell_index(global_position.x, global_position.y)
	level.collision_grid.add_to_cell(self, collision_cell_index)
	
	cash_awarded.resize(BloonType.size())
	cash_awarded.fill(false)
	
	match bloon_type:
		BloonType.CERAMIC:
			max_health = 10
		BloonType.MOAB:
			max_health = 200
		BloonType.BFB:
			max_health = 700
		BloonType.BOSS:
			max_health = 4000
		_:
			max_health = 1
 	
	health = max_health
 	
	set_type(p_type)
	update_sprite()
	InterpolationManager.register(self)
 
func reset_status_effects() -> void:
	reset_ice()
	permaFrostSpeedScale = 1.0
	reset_glue()
	stunned = false
	stunCountDown = 0.0
	burning = false
	burnCountDown = 0.0
	burnInterval = 0.0
	burnLifeSpan = 0.0

func process(delta: float) -> void:
	if tile == null or bloon_type == -1:
		return
	
	var loc2 = max(6.6 * ((level.current_round - 85) / (200.0 - 85.0)), 1.0)
	
	if iced:
		loc2 *= 0
		ice_countdown -= delta
		
		if ice_countdown <= 0:
			reset_ice()
			update_sprite()
			calculate_immunity()
	
	if glued:
		if bloon_type != BloonType.CERAMIC:
			loc2 *= glue_speed_scale
		
		glue_countdown -= delta
		if glue_countdown <= 0:
			reset_glue()
			update_sprite()
			calculate_immunity()
	
	var distance = progress_step * delta * loc2
	tile_progress += distance
	overall_progress += distance
	
	tile.update_bloon_position(self)
	
	var new_index = level.collision_grid.get_cell_index(global_position.x, global_position.y)
	if new_index != collision_cell_index:
		level.collision_grid.switch_cells(self, collision_cell_index, new_index)
		collision_cell_index = new_index
	
	if is_regen:
		if not iced:
			regen_countdown -= delta
			if regen_countdown <= 0:
				regen_countdown += regen_interval
				regenerate()

func create_children(amount: int, is_zebra: bool) -> void:
	if amount <= 0:
		return
	
	var parent_node = get_parent()
	var base_progress = tile_progress
	var progress_offset = min(60.0 / float(amount), 20.0)
	
	for i in range(amount):
		var offset_progress = (i + 1) * progress_offset
		var child_progress = base_progress - offset_progress
		var unwound = _unwind_progress(tile, child_progress)
		
		var inst = Pool.get_obj(AssetManager.grab("bloon")) as Bloon
		
		var child_spawn_order = spawn_order_index + spawn_order_offsets[bloon_type] * i
		if was_regenerated or child_spawn_order < 0:
			global_spawn_counter -= 10
			child_spawn_order = global_spawn_counter
		
		var child_type = int(bloon_type)
		if is_zebra:
			child_type = max(0, child_type - (1 - (i % 2)))
		
		parent_node.add_child(inst)
		
		inst.initialize(child_type, unwound.tile, unwound.progress, is_regen, is_camo, child_spawn_order, level)
		
		inst.spawn_time = spawn_time
		if was_regenerated or special_flag:
			inst.special_flag = true
		
		inst.parentIDs.append(id)
		for pid in parentIDs:
			inst.parentIDs.append(pid)
		
		inst.iced = iced
		inst.ice_countdown = ice_countdown
		inst.permaFrostSpeedScale = permaFrostSpeedScale
		inst.viralIce = viralIce
		inst.iceShards = iceShards
		inst.iced_by = iced_by
		inst.freezeLayers = freezeLayers
		inst.arcticWind = arcticWind
		inst.arcticWindCountdown = arcticWindCountdown
		inst.glued = glued
		inst.glue_countdown = glue_countdown
		inst.glueCorrosionInterval = glueCorrosionInterval
		inst.glueCorrosionCountDown = glueCorrosionCountDown
		inst.glue_speed_scale = glue_speed_scale
		inst.glue_soak = glue_soak
		inst.glueCash = glueCash
		inst.glue_tower = glue_tower
		
		inst.overall_progress = overall_progress - offset_progress
		
		if stunInherited:
			inst.stunned = stunned
			inst.stunInherited = stunInherited
			inst.stunCountDown = stunCountDown
		else:
			inst.stunned = false
			inst.stunCountDown = 0
		inst.stunInherited = false
		
		inst.burning = burning
		inst.burnCountDown = burnCountDown
		inst.burnInterval = burnInterval
		inst.burnLifeSpan = burnLifeSpan
		inst.burnCash = burnCash
		
		inst.regen_ceiling = regen_ceiling
		inst.regen_interval = regen_interval
		inst.regen_countdown = regen_countdown
		inst.was_white = was_white
		inst.rotation = rotation
		
		inst.tile.update_bloon_position(inst)

func damage(damage_amount: int, cash_scale: float, tower: Tower, show_pop: bool = true) -> void:
	if self.bloon_type == -1:
		return
	
	var loc5: int = 0
	var loc6: int = health
	
	while damage_amount > 0 and bloon_type - loc5 >= BloonType.CERAMIC:
		loc6 -= 1
		damage_amount -= 1
		if loc6 == 0:
			loc5 += 1
			loc6 = health_by_type[bloon_type - loc5]
	
	loc5 += damage_amount
	
	if loc5 != 0:
		degrade(loc5, cash_scale, tower, show_pop)
	else:
		if bloon_type == BloonType.CERAMIC:
			SoundManager.play("ceramic_bloon_hit")
		elif bloon_type >= BloonType.MOAB:
			SoundManager.play("moab_damage_" + str(randi_range(1, 3)))
			pass
		
		health = loc6
		update_sprite()

func degrade(layers: int, _cash_scale: float, tower: Tower, show_pop) -> void:
	if bloon_type == -1:
		return
	
	layers = min(layers, bloon_type + 1)
	
	if show_pop and level.bursts_this_process < 15:
		level.bursts_this_process += 1
		SoundManager.play("pop_" + str(randi_range(1, 4)))
		
		var burst = Pool.get_obj(AssetManager.grab("burst")) as Burst
		burst.initialize()
		burst.position = position
		level.add_child(burst)
	
	if bloon_type == BloonType.BOSS:
		SoundManager.play("moab_destroyed_big")
	elif bloon_type == BloonType.BFB:
		SoundManager.play("moab_destroyed_med")
	elif bloon_type == BloonType.MOAB:
		SoundManager.play("moab_destroyed_short")
	
	var total_multiplier: int = 1
	var event_multiplier: int = 1
	var zebra_flag: bool = false
	var cur_type: int = int(bloon_type)
	
	var calculated_cash: float = 0.0
	var calculated_pops: int = 0
	var calculated_xp: float = 0.0
	
	var current_layer_width: int = 1
	
	var remaining_layers = layers
	while remaining_layers > 0:
		if not cash_awarded[cur_type]:
			cash_awarded[cur_type] = true
			
			if level.current_round >= 85 and cur_type == BloonType.CERAMIC:
				calculated_cash += _cash_scale * current_layer_width * level.cash_multiplier * 95
				calculated_xp += current_layer_width * 95
			else:
				calculated_cash += _cash_scale * current_layer_width * level.cash_multiplier
				calculated_xp += current_layer_width
		
		if cur_type <= 0:
			for _k in range(event_multiplier):
				bloon_popped.emit(self)
			destroy()
			post_degrade(tower, calculated_cash, calculated_pops, calculated_xp)
			return
		
		if level:
			if level.current_round < 85:
				total_multiplier *= child_count_by_type[cur_type]
			elif cur_type >= BloonType.MOAB:
				total_multiplier *= child_count_by_type[cur_type]
		
		zebra_flag = (cur_type == BloonType.ZEBRA)
		
		for _k in range(event_multiplier):
			bloon_popped.emit(self)
		
		event_multiplier *= child_count_by_type[cur_type]
		
		if cur_type == BloonType.WHITE or cur_type == BloonType.LEAD or cur_type == BloonType.ZEBRA:
			cur_type -= 2
		else:
			cur_type -= 1
		
		remaining_layers -= 1
		
		if !glue_soak:
			reset_glue()
			calculate_immunity()
	
	set_type(cur_type)
	
	if bloon_type == -1:
		destroy()
		return
	else:
		update_sprite()
	
	var to_spawn = total_multiplier - 1
	if to_spawn > 0:
		create_children(to_spawn, zebra_flag)
	
	post_degrade(tower, calculated_cash, calculated_pops, calculated_xp)
	parentIDs.append(id)
	id = Bloon.next_id
	Bloon.next_id += 1

func regenerate() -> void:
	if bloon_type < regen_ceiling:
		if bloon_type == BloonType.PINK and was_white or bloon_type == BloonType.WHITE:
			bloon_type = bloon_type + 1 as BloonType
		elif bloon_type == BloonType.BLACK:
			if regen_ceiling == BloonType.LEAD:
				bloon_type = bloon_type + 1 as BloonType
			else:
				bloon_type = bloon_type + 2 as BloonType
		
		set_type(bloon_type + 1)
		cash_awarded[bloon_type] = true
		was_regenerated = true
		update_sprite()

func hit_previously(proj: Projectile) -> bool:
	if id in proj.hit_bloons:
		return true
		
	for parent_id in parentIDs:
		if parent_id in proj.hit_bloons:
			return true
			
	return false

func handle_collision(proj: Projectile) -> void:
	if proj.def == null:
		return
	
	var type_id = bloon_type
	var tower = proj.owner_tower
	var damage_effect = proj.def.damage_effect
	var ice_effect: IceEffectDef = null
	var glue_effect: GlueEffectDef = null
	
	#var pop_cash_scale: float = proj.def.get("pop_cash_scale") if proj.def.get("pop_cash_scale") else 1.0
	
	if bloon_type < BloonType.MOAB:
		ice_effect = proj.def.ice_effect
		glue_effect = proj.def.glue_effect
	
	if damage_effect:
		var can_damage_type = true
		var can_break_ice = iced == false or damage_effect.can_break_ice
		
		if damage_effect.cant_break_types and type_id in damage_effect.cant_break_types:
			can_damage_type = false
		
		if can_damage_type and can_break_ice:
			proj.hit_bloons.append(id)
		elif iced:
			SoundManager.play("frozen_bloon_hit")
			proj.pierce = 0
			return
		elif type_id == BloonType.LEAD:
			SoundManager.play("metal_bloon_hit")
			proj.pierce = 0
			return
		else:
			return
	else:
		proj.hit_bloons.append(id)
	
	if proj.def.get("remove_camo"):
		if is_camo:
			is_camo = false
	
	if proj.def.get("remove_regen"):
		if is_regen:
			is_regen = false
	
	if ice_effect:
		iced_by = proj.owner_tower
		
		if proj.lifespan != 0:
			iced = true
			ice_countdown = ice_effect.lifespan
			update_sprite()
			calculate_immunity()
	
	if glue_effect:
		glue_tower = proj.owner_tower
		glue_effect_def = glue_effect
		glued = true
		glue_countdown = glue_effect.lifespan
		glue_speed_scale = glue_effect.speed_scale
		glue_soak = glue_effect.soak
		#glueCash = pop_cash_scale
		update_sprite()
		calculate_immunity()
	
	if damage_effect:
		var can_dmg = true
		if damage_effect.cant_break_types and type_id in damage_effect.cant_break_types:
			can_dmg = false
			
		if can_dmg:
			var final_damage = float(damage_effect.damage)
			
			if type_id >= BloonType.MOAB:
				if damage_effect.get("blimp_scale"):
					final_damage *= damage_effect.blimp_scale
			
			if type_id == BloonType.CERAMIC:
				if damage_effect.get("ceramic_scale"):
					final_damage *= damage_effect.ceramic_scale
			
			if damage_effect.get("kill") and type_id < BloonType.MOAB:
				damage(health, 1, tower, damage_effect.show_pop)
			elif damage_effect.get("peel_layer") and type_id < BloonType.MOAB:
				damage(1, 1, tower, damage_effect.show_pop)
			else:
				damage(int(final_damage), 1, tower, damage_effect.show_pop)

func calculate_immunity() -> void:
	if bloon_type == -1:
		return
	
	immunity = base_immunities_by_type[bloon_type]
	
	if is_camo:
		immunity |= BloonImmunity.IMMUNITY_NO_DETECTION
	if glue_countdown != 0:
		immunity |= BloonImmunity.IMMUNITY_GLUE

func get_pop_value() -> float:
	return rbe_by_type[bloon_type] * cash_multiplier

func post_degrade(_tower, cash_earned, _pop_count: int, _xp_amount: float) -> void:
	level.add_cash(cash_earned)

func _unwind_progress(p_tile: Tile, p_progress: float) -> Dictionary:
	var current_tile = p_tile
	var current_progress = p_progress
	
	while current_progress < 0.0 and current_tile.previous_tiles.size() > 0:
		current_tile = current_tile.previous_tiles[0]
		current_progress += current_tile.tile_length
	
	if current_progress < 0.0:
		current_progress = 0.0
	
	return { "tile": current_tile, "progress": current_progress }

func is_in_tunnel() -> bool:
	if tile == null:
		return false
		
	if bloon_type >= 11:
		return false
		
	if tile.transition_type == Tile.UNDERPASS: # or tile.transition_type == Tile.TELEPORT
		return true
		
	return false

func update_layer_order() -> void:
	if tile == null:
		return
	
	if bloon_type >= 11:
		visuals.z_index = 4
		return
	
	visuals.z_index = tile.layer * 10

func get_distance_to_end() -> float:
	var base = tile.precalculated_distance_to_end if tile.precalculated_distance_to_end != -1 else tile.get_distance_to_end()
	return base - tile_progress

func get_distance_to_start() -> float:
	var base = tile.precalculated_distance_to_start if tile.precalculated_distance_to_start != -1 else tile.get_distance_to_start()
	return base - tile.tile_length + tile_progress

func reset_ice():
	iced = false
	ice_countdown = 0

func reset_glue():
	glue_countdown = 0
	glued = false
	glue_effect_def = null
	glue_speed_scale = 1.0
	glue_soak = false

func set_type(new_type: BloonType) -> void:
	if is_regen:
		if bloon_type == regen_ceiling:
			regen_countdown = regen_interval
	
	bloon_type = new_type
	max_health = health_by_type[new_type]
	health = max_health
	progress_step = BASE_SPEED * (speed_multiplier_by_type[bloon_type] + difficulty_speed_modifier) * speed_modifier
	
	if level.current_round >= 85 and new_type == BloonType.CERAMIC:
		health = 38
	if new_type >= BloonType.MOAB:
		@warning_ignore("narrowing_conversion")
		max_health = health * (1.5 + 0 * 0.02)
		health = max_health
	
	if bloon_type == BloonType.WHITE:
		was_white = true
	
	calculate_immunity()

func update_sprite() -> void:
	if is_regen:
		sprite.texture = AssetManager.grab("RegenBloon")[bloon_type]
	else:
		sprite.texture = AssetManager.grab("NormalBloon")[bloon_type]
	
	if is_camo and is_regen:
		camo_effect.texture = AssetManager.grab("CamoEffect")[11]
	elif is_camo:
		camo_effect.texture = AssetManager.grab("CamoEffect")[bloon_type]
	else: 
		camo_effect.texture = null
	
	if iced and is_regen:
		ice_effect.texture = AssetManager.grab("IceEffect")[11]
	elif iced:
		ice_effect.texture = AssetManager.grab("IceEffect")[bloon_type]
	else:
		ice_effect.texture = null
	
	if glued and is_regen:
		glue_effect.texture = AssetManager.grab("GlueEffect")[11]
	elif glued:
		glue_effect.texture = AssetManager.grab("GlueEffect")[bloon_type]
	else: 
		glue_effect.texture = null
	
	if sprite.texture:
		radius = sprite.texture.get_size().y / 2.0
		if radius > Bloon.max_radius:
			Bloon.max_radius = radius

func _exit_tree() -> void:
	InterpolationManager.unregister(self)
 
func destroy() -> void:
	if bloon_type == BloonType.INVALID:
		return
 	
	if level and level.collision_grid:
		level.collision_grid.remove_from_cell(self, collision_cell_index)
 	
	bloon_type = BloonType.INVALID
	bloon_removed.emit()
 	
	Pool.release(self)
