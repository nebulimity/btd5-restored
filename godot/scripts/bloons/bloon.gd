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

static var cash_multiplier: float = 1.0

var tile: Tile = null
var tile_progress: float = 0.0
var overall_progress: float = 0.0

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

var level: Level = null
var sounds: Node = null

@onready var sprite: Sprite2D = $Sprite2D

signal bloon_removed
signal bloon_popped
static var next_id: int = 0
var id: int = 0
var bursts_this_process: int = 0

func initialize(p_type: BloonType, start_tile: Tile, start_progress: float = 0.0, p_is_regen: bool = false, p_is_camo: bool = false, p_spawn_order: int = 0, _p_level: Level = null):
	bloon_type = p_type
	tile = start_tile
	tile_progress = start_progress
	overall_progress = 0.0
	is_camo = p_is_camo
	is_regen = p_is_regen
	spawn_order_index = p_spawn_order
	level = self.get_parent().get_parent().get_node("Level") # temp
	sounds = self.get_parent().get_parent().get_node("Sounds") # temp
	
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

func leak() -> void:
	bloon_removed.emit()
	queue_free()
		
func damage(damage_amount: int, cash_scale: float, tower: Tower, show_pop: bool = true) -> void:
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
	
	if show_pop and bursts_this_process < 15:
		bursts_this_process += 1
		if sounds:
			sounds.get_node("Pop" + str(randi_range(1, 4))).play()
		
		var burst = Burst.new()
		burst.initialize(position.x, position.y)
		level.add_child(burst)
	
	if bloon_type == BloonType.BOSS:
		# play zomg destroy sound
		pass
	elif bloon_type == BloonType.BFB:
		# play bfb destroy sound
		pass
	elif bloon_type == BloonType.MOAB:
		# play moab destroy sound
		pass
	
	var current_type = bloon_type
	var children_count = 1
	
	for i in range(layers):
		if current_type < 0:
			bloon_removed.emit()
			bloon_popped.emit()
			queue_free()
			return
		
		var child_spawn_count = children_count
		if level:
			if level.current_round < 85:
				child_spawn_count *= child_count_by_type[current_type]
			elif current_type >= BloonType.MOAB:
				child_spawn_count *= child_count_by_type[current_type]
		
		for _i in range(child_spawn_count):
			bloon_popped.emit()
		
		if current_type == BloonType.WHITE or current_type == BloonType.LEAD or current_type == BloonType.ZEBRA:
			current_type = current_type - 2 as BloonType
		else:
			current_type = current_type - 1 as BloonType
		
		if current_type >= 0:
			children_count = child_count_by_type[current_type + 1]
	
	bloon_type = current_type
	
	if bloon_type < 0:
		bloon_removed.emit()
		queue_free()
	else:
		update_sprite()

func update_sprite() -> void:
	sprite.texture = BLOON_TEXTURES[bloon_type]

func get_pop_value() -> float:
	return rbe_by_type[bloon_type] * cash_multiplier
