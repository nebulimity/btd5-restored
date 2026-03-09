class_name Wave
extends RefCounted

class SpawnerInstance:
	var type_index: int
	var init_type_index: int
	var camo: bool
	var regen: bool
	var spawn_times: Array[float]
	var current_index: int = 0
	var spawn_order_offset: int = 0
	
	func _init(p_count: int, p_start: float, p_interval: float, p_type: int, p_camo: bool, p_regen: bool):
		type_index = p_type
		init_type_index = p_type
		camo = p_camo
		regen = p_regen
		spawn_times = []
		
		for i in range(p_count):
			spawn_times.append(p_start + i * p_interval)
	
	func clone() -> SpawnerInstance:
		var interval = 0.0
		if spawn_times.size() > 1:
			interval = spawn_times[1] - spawn_times[0]
		var cloned = SpawnerInstance.new(spawn_times.size(), spawn_times[0], interval, init_type_index, camo, regen)
		cloned.type_index = type_index
		return cloned
	
	func get_rbe() -> int:
		return Bloon.rbe_by_type[type_index] * spawn_times.size()

var wave_spawners: Array[SpawnerInstance] = []
var active_spawners: Array[SpawnerInstance] = []
var rbe: int = 0
var rbe_density: float = 0.0
var wave_length: float = 0.0

static func calculate_spawn_interval(round_number: int) -> float:
	if round_number > 40:
		return 1.0 - 0.4 - 0.0015 * round_number
	return 1.0 - 0.01 * round_number

func create_from_round_def(round_def: RoundFactory.RoundDef) -> void:
	for group in round_def.groups:
		for spawner_def in group.spawners:
			var spawn_interval: float
			if spawner_def.count == 1:
				spawn_interval = 0.0
			else:
				spawn_interval = spawner_def.length / float(spawner_def.count - 1)
			
			var spawner = SpawnerInstance.new(
				spawner_def.count,
				spawner_def.start,
				spawn_interval,
				group.bloon.type,
				group.bloon.camo,
				group.bloon.regen
			)
			
			rbe += spawner.get_rbe()
			wave_spawners.append(spawner)
			update_round_length(spawner)
	
	if wave_length > 0:
		rbe_density = float(rbe) / wave_length

func start() -> void:
	active_spawners.clear()
	
	var spawn_order_offset = 0
	for spawner in wave_spawners:
		var cloned = spawner.clone()
		cloned.spawn_order_offset = spawn_order_offset
		spawn_order_offset += Bloon.spawn_order_offsets[cloned.type_index] * cloned.spawn_times.size()
		active_spawners.append(cloned)

func process(time: float, spawner_node: Node, map_def: LevelDef) -> void:
	for spawner in active_spawners:
		while spawner.current_index < spawner.spawn_times.size():
			if time >= spawner.spawn_times[spawner.current_index]:
				spawn_bloon(spawner, time - spawner.spawn_times[spawner.current_index], spawner_node, map_def)
				spawner.current_index += 1
			else:
				break

func spawn_bloon(spawner: SpawnerInstance, time_offset: float, spawner_node: Node, map_def: LevelDef) -> void:
	var start_tile = map_def.get_start_tile()
	if not start_tile:
		return
	
	var initial_progress = time_offset * Bloon.speed_multiplier_by_type[spawner.type_index] * Bloon.BASE_SPEED
	var spawn_order = spawner.spawn_order_offset + Bloon.spawn_order_offsets[spawner.type_index] * spawner.current_index
	
	var bloon_scene = preload("res://scenes/entities/bloon.tscn")
	var bloon = bloon_scene.instantiate() as Bloon
	spawner_node.add_child(bloon)
	bloon.get_parent().move_child(bloon, 0)
	bloon.initialize(spawner.type_index, start_tile, initial_progress, spawner.regen, spawner.camo, spawn_order)

func is_complete() -> bool:
	for spawner in active_spawners:
		if spawner.current_index != spawner.spawn_times.size():
			return false
	return true

func update_round_length(spawner: SpawnerInstance) -> void:
	for spawn_time in spawner.spawn_times:
		wave_length = max(wave_length, spawn_time)
