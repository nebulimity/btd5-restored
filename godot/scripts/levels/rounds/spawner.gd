class_name Spawner
extends Node

var wave_set: WaveSet
var map_def: LevelDef
var round_factory: RoundFactory

var current_round: int = 0
var round_time: float = 0.0
var active_spawners: Array = []  # {spawner_def, group_def, spawn_index}

var level: Level = null

signal rbe_changed(new_rbe: int)

func _ready():
	round_factory = RoundFactory.new()
	wave_set = WaveSet.new()
	add_child(wave_set)
	wave_set.rbe_changed.connect(_on_wave_set_rbe_changed)

func _on_wave_set_rbe_changed(new_rbe: int):
	rbe_changed.emit(new_rbe)

func setup(p_map_def: LevelDef, p_level: Level):
	map_def = p_map_def
	level = p_level
	wave_set.setup(self, map_def, round_factory, level)

func start_round(round_number: int):
	wave_set.start_wave(round_number)

func is_round_complete() -> bool:
	return not wave_set.is_running()

func get_current_rbe() -> int:
	return wave_set.get_current_rbe()

func _process(_delta: float) -> void:
	if active_spawners.is_empty():
		return
	
	round_time += TimeManager.delta
	
	for spawner_data in active_spawners:
		var spawner_def = spawner_data.spawner_def
		var group_def = spawner_data.group_def
		var spawn_index = spawner_data.spawn_index
		
		while spawn_index < spawner_def.count:
			var spawn_time = spawner_def.start + spawn_index * spawner_def.length
			if round_time >= spawn_time:
				spawn_bloon(group_def.bloon.type, group_def.bloon.camo, group_def.bloon.regen)
				spawn_index += 1
				spawner_data.spawn_index = spawn_index
			else:
				break

func spawn_bloon(type: int, camo: bool = false, regen: bool = false):
	var start_tile = map_def.get_start_tile()
	
	var bloon = Pool.get_obj(AssetManager.grab("bloon")) as Bloon
	bloon.initialize(type, start_tile, 0.0, regen, camo, 0, level)
	add_child(bloon)
	bloon.get_parent().move_child(bloon, 0)
