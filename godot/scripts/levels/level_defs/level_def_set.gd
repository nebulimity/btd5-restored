class_name LevelDefSet
extends RefCounted

static var _levels: Array[LevelDef] = []
static var _built: bool = false

static func _build_registry() -> void:
	if _built:
		return
	_built = true

	var monkey_lane = MonkeyLaneDef.new()
	monkey_lane.setup()
	_levels.append(monkey_lane)

	var park = ParkDef.new()
	park.setup()
	_levels.append(park)
	
	var rink = RinkDef.new()
	rink.setup()
	_levels.append(rink)
	
	var archipelago = ArchipelagoDef.new()
	archipelago.setup()
	_levels.append(archipelago)

static func get_level_def(level_id: String) -> LevelDef:
	_build_registry()
	for def in _levels:
		if def.id == level_id:
			return def
	return null

static func get_all_levels() -> Array[LevelDef]:
	_build_registry()
	return _levels
