class_name Bloon
extends Node2D

enum BloonType {
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
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	10,
	200,
	700,
	4000
]

static var child_count_by_type = [
	1,
	1,
	1,
	1,
	1,
	2,
	2,
	2,
	2,
	2,
	2,
	4,
	4,
	4
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

const BLOON_TEXTURES = [
	preload("res://assets/sprites/bloons/0.svg"),  # RED
	preload("res://assets/sprites/bloons/1.svg"),  # BLUE
	preload("res://assets/sprites/bloons/2.svg"),  # GREEN
	preload("res://assets/sprites/bloons/3.svg"),  # YELLOW
	preload("res://assets/sprites/bloons/4.svg"),  # PINK
	preload("res://assets/sprites/bloons/5.svg"),  # BLACK
	preload("res://assets/sprites/bloons/6.svg"),  # WHITE
	preload("res://assets/sprites/bloons/7.svg"),  # LEAD
	preload("res://assets/sprites/bloons/8.svg"),  # ZEBRA
	preload("res://assets/sprites/bloons/9.svg"),  # RAINBOW
	preload("res://assets/sprites/bloons/10.svg"), # CERAMIC
	preload("res://assets/sprites/bloons/11.svg"), # MOAB
	preload("res://assets/sprites/bloons/12.svg"), # BFB
	preload("res://assets/sprites/bloons/13.svg"), # BOSS (ZOMG)
]

static var max_radius: float = 10.0

static var cash_multiplier: float = 1.0

var tile: Tile = null
var tile_progress: float = 0.0
var overall_progress: float = 0.0
var last_grid_pos: Vector2

var bloon_type: BloonType = BloonType.RED
var health: int = 1
var max_health: int = 1
var is_camo: bool = false
var is_regen: bool = false
var spawn_order_index: int = 0

const BASE_SPEED: float = 70.0
static var difficulty_speed_modifier: float = 0.0

var speed_modifier: float = 1.0
var is_frozen: bool = false
var is_glued: bool = false
var is_stunned: bool = false
var is_dead: bool = false

var iceCountdown: float = 0.0
var permaFrostSpeedScale: float = 1.0
var viralIce: bool = false
var viralDepth: int = 0
var iceShards: bool = false
var freezeLayers: int = 1
var arcticWind: float = 1.0
var arcticWindCountdown: int = 0
var icedBy = null

var glueCountdown: float = 0.0
var glueCorrosionInterval: float = 0.0
var glueCorrosionCountDown: float = 0.0
var glueSpeedScale: float = 1.0
var glueSoak: bool = false
var glueCash: float = 1.0

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

@onready var sprite: Sprite2D = $Sprite2D

signal bloon_removed
signal bloon_popped
static var next_id: int = 0
var id: int = 0
var bursts_this_process: int = 0

func _init() -> void:
	process_priority = 0

func initialize(p_type: BloonType, start_tile: Tile, start_progress: float = 0.0, p_is_regen: bool = false, p_is_camo: bool = false, p_spawn_order: int = 0, _p_level: Level = null):
	bloon_type = p_type
	tile = start_tile
	tile_progress = start_progress
	overall_progress = 0.0
	is_camo = p_is_camo
	is_regen = p_is_regen
	spawn_order_index = p_spawn_order

	spawn_time = p_spawn_order
	was_regenerated = false
	special_flag = false
	level = self.get_parent().get_parent().get_node("Level") #_p_level
	sounds = level.get_node("../Sounds")
	
	id = Bloon.next_id
	Bloon.next_id += 1
	
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
	
	if tile:
		tile.update_bloon_position(self)
	
	update_sprite()
	
	if level and level.collision_grid:
		level.collision_grid.add_bloon(self)
		last_grid_pos = global_position

func _process(delta: float) -> void:
	if tile == null or bloon_type < 0:
		return
		
	bursts_this_process = 0
	
	var type_speed_mult = speed_multiplier_by_type[bloon_type]
	var effective_speed = BASE_SPEED * (type_speed_mult + difficulty_speed_modifier) * speed_modifier
	
	if is_frozen:
		effective_speed = 0.0
	elif is_stunned:
		effective_speed = 0.0
	
	var distance = effective_speed * delta
	tile_progress += distance
	overall_progress += distance
	
	tile.update_bloon_position(self)
	
	if level and level.collision_grid:
		level.collision_grid.move_bloon(self, last_grid_pos)
		last_grid_pos = global_position

func leak() -> void:
	bloon_removed.emit()
	queue_free()

func create_children(amount: int, is_zebra: bool) -> void:
	if amount <= 0:
		return
	
	var bloon_scene = load("res://scenes/entities/bloon.tscn")
	var parent_node = get_parent()
	var base_progress = tile_progress
	var progress_offset = min(60.0 / float(amount), 20.0)
	
	for i in range(amount):
		var offset_progress = (i + 1) * progress_offset
		var child_progress = base_progress - offset_progress
		var unwound = _unwind_progress(tile, child_progress)
		
		var inst = bloon_scene.instantiate() as Bloon
		
		var child_spawn_order = spawn_order_index + spawn_order_offsets[bloon_type] * i
		if was_regenerated or child_spawn_order < 0:
			global_spawn_counter -= 10
			child_spawn_order = global_spawn_counter
		
		var child_type = int(bloon_type)
		if is_zebra:
			child_type = max(0, child_type - (1 - (i % 2)))
		
		parent_node.add_child(inst)
		
		inst.initialize(child_type, unwound.tile, unwound.progress, is_regen, is_camo, child_spawn_order, level)
		#inst.initialize(child_type, tile, base_progress - offset_progress, is_regen, is_camo, child_spawn_order, level)
		
		inst.spawn_time = spawn_time
		if was_regenerated or special_flag:
			inst.special_flag = true
		
		inst.parentIDs.append(id)
		for pid in parentIDs:
			inst.parentIDs.append(pid)
		
		inst.is_frozen = is_frozen
		inst.iceCountdown = iceCountdown
		inst.permaFrostSpeedScale = permaFrostSpeedScale
		inst.viralIce = viralIce
		inst.iceShards = iceShards
		inst.icedBy = icedBy
		inst.freezeLayers = freezeLayers
		inst.arcticWind = arcticWind
		inst.arcticWindCountdown = arcticWindCountdown
		inst.is_glued = is_glued
		inst.glueCountdown = glueCountdown
		inst.glueCorrosionInterval = glueCorrosionInterval
		inst.glueCorrosionCountDown = glueCorrosionCountDown
		inst.glueSpeedScale = glueSpeedScale
		inst.glueSoak = glueSoak
		inst.glueCash = glueCash
		
		inst.overall_progress = overall_progress - offset_progress
		
		if stunInherited:
			inst.is_stunned = is_stunned
			inst.stunInherited = stunInherited
			inst.stunCountDown = stunCountDown
		else:
			inst.is_stunned = false
			inst.stunCountDown = 0
		inst.stunInherited = false
		
		inst.burning = burning
		inst.burnCountDown = burnCountDown
		inst.burnInterval = burnInterval
		inst.burnLifeSpan = burnLifeSpan
		inst.burnCash = burnCash
		
		inst.tile.update_bloon_position(inst)

func damage(damage_amount: int, cash_scale: float, tower: Tower, show_pop: bool = true) -> void:
	if is_dead:
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
			# play ceramic hit sound
			pass
		elif bloon_type == BloonType.MOAB:
			# play moab hit sound
			pass
		
		health = loc6
		update_sprite()

func degrade(layers: int, _cash_scale: float, _tower: Tower, show_pop: bool = true) -> void:
	if bloon_type < 0:
		return
	
	layers = min(layers, bloon_type + 1)
	
	if show_pop and bursts_this_process < 15 and level:
		bursts_this_process += 1
		if sounds:
			sounds.get_node("Pop" + str(randi_range(1, 4))).play()
		
		var burst = Burst.new()
		burst.initialize(position.x, position.y)
		level.add_child(burst)
	
	if bloon_type == BloonType.BOSS:
		pass
	elif bloon_type == BloonType.BFB:
		pass
	elif bloon_type == BloonType.MOAB:
		pass
	
	var total_multiplier: int = 1
	var event_multiplier: int = 1
	var zebra_flag: bool = false
	var cur_type: int = int(bloon_type)
	
	var remaining_layers = layers
	while remaining_layers > 0:
		if cur_type <= 0:
			for _k in range(event_multiplier):
				bloon_popped.emit(self)
			bloon_removed.emit()
			is_dead = true
			queue_free()
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
	
	bloon_type = cur_type as BloonType
	
	if bloon_type < 0:
		bloon_removed.emit()
		is_dead = true
		queue_free()
		return
	else:
		update_sprite()
	
	var to_spawn = total_multiplier - 1
	if to_spawn > 0:
		create_children(to_spawn, zebra_flag)
	
	parentIDs.append(id)
	id = Bloon.next_id
	Bloon.next_id += 1

func _unwind_progress(p_tile: Tile, p_progress: float) -> Dictionary:
	var current_tile = p_tile
	var current_progress = p_progress
	
	while current_progress < 0.0 and current_tile.previous_tile != null:
		current_tile = current_tile.previous_tile
		current_progress += current_tile.tile_length
	
	if current_progress < 0.0:
		current_progress = 0.0
	
	return { "tile": current_tile, "progress": current_progress }

func update_sprite() -> void:
	sprite.texture = BLOON_TEXTURES[bloon_type]
	if sprite.texture:
		radius = sprite.texture.get_size().y / 2.0
		if radius > Bloon.max_radius:
			Bloon.max_radius = radius

func get_pop_value() -> float:
	return rbe_by_type[bloon_type] * cash_multiplier

func _exit_tree() -> void:
	if level and level.collision_grid:
		level.collision_grid.remove_bloon(self, last_grid_pos)
