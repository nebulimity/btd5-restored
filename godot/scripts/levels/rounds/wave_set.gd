class_name WaveSet
extends Node

var rounds_def: Array[RoundFactory.RoundDef] = []
var current_wave: Wave = null
var time: float = 0.0
var round_factory: RoundFactory
var spawner_node: Node
var map_def: MonkeyLaneDef

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

signal rbe_changed(new_rbe: int)

func _ready():
	rng.seed = 0

func initialize_from_rounds_def(p_rounds_def: Array[RoundFactory.RoundDef]):
	rounds_def = p_rounds_def

func setup(p_spawner_node: Node, p_map_def: MonkeyLaneDef, p_round_factory: RoundFactory):
	spawner_node = p_spawner_node
	map_def = p_map_def
	round_factory = p_round_factory
	rounds_def = []
	for i in range(round_factory.get_total_rounds()):
		rounds_def.append(round_factory.get_round(i))

func start_wave(round_number: int) -> void:
	time = 0.0
	
	if rounds_def.is_empty():
		return
	
	if round_number < rounds_def.size():
		current_wave = Wave.new()
		current_wave.create_from_round_def(rounds_def[round_number])
	else:
		current_wave = create_freeplay_wave(round_number)
	
	current_wave.start()
	print("Started round %d - RBE: %d, Length: %.2fs" % [round_number + 1, current_wave.rbe, current_wave.wave_length])
	
	rbe_changed.emit(current_wave.rbe)

func _process(delta: float) -> void:
	if current_wave == null:
		return
	
	time += delta
	current_wave.process(time, spawner_node, map_def)

func is_running() -> bool:
	return current_wave != null and not current_wave.is_complete()

func get_current_rbe() -> int:
	if current_wave:
		return current_wave.rbe
	return 0

func get_current_wave_length() -> float:
	if current_wave:
		return current_wave.wave_length
	return 0.0

func create_freeplay_wave(round_number: int) -> Wave:
	var wave = Wave.new()
	var rounds_past_85 = round_number - 85
	
	var total_waves = get_total_waves(rounds_past_85)
	var spawn_time = 0.0
	
	for i in range(total_waves):
		var bloon_count = rng.randi_range(total_waves, total_waves + 6)
		var interval = get_interval(rounds_past_85)
		var bloon_type = get_random_type(rounds_past_85)
		
		if bloon_type == Bloon.BloonType.CERAMIC:
			interval /= 3.0
			bloon_count *= 3
		elif bloon_type == Bloon.BloonType.BOSS:
			interval *= 4.0
			bloon_count = int(bloon_count / 3.0)
		
		var spawner = Wave.SpawnerInstance.new(bloon_count, spawn_time, interval, bloon_type, false, false)
		wave.rbe += spawner.get_rbe()
		wave.wave_spawners.append(spawner)
		wave.update_round_length(spawner)
		
		spawn_time += bloon_count * interval
	
	if wave.wave_length > 0:
		wave.rbe_density = float(wave.rbe) / wave.wave_length
	
	return wave

func get_total_waves(rounds_past_85: int) -> int:
	if rounds_past_85 > 10:
		return mini(16 + int((rounds_past_85 - 10) * 0.2), 20)
	return rounds_past_85 + 6

func get_random_type(rounds_past_85: int) -> int:
	var rand_val = rng.randi_range(0, rounds_past_85 + 100)
	if rand_val > 95:
		return Bloon.BloonType.BOSS
	elif rand_val > 60:
		return Bloon.BloonType.BFB
	elif rand_val > 20:
		return Bloon.BloonType.MOAB
	else:
		return Bloon.BloonType.CERAMIC

func get_interval(rounds_past_85: int) -> float:
	var base_interval = max(0.425 - rounds_past_85 * 0.005, 0.2)
	return base_interval * (1.0 + rng.randf())
