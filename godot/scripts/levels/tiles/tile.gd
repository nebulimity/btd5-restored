class_name Tile
extends RefCounted

const NORMAL = 0
const UNDERPASS = 1
const OVERPASS = 2

var way_points: Array[Vector2] = []
var next_tiles: Array[Tile] = []
var previous_tiles: Array[Tile] = []
var tile_length: float = 0.0
var transition_type: int = NORMAL
var is_wind: bool = false
var layer: int = 0

var precalculated_distance_to_end: float = -1.0
var precalculated_distance_to_start: float = -1.0

func get_distance_to_end() -> float:
	if precalculated_distance_to_end != -1.0:
		return precalculated_distance_to_end
	var length = 0.0 if transition_type == OVERPASS else tile_length
	var best = 0.0
	for next in next_tiles:
		var d = next.get_distance_to_end()
		if d > best:
			best = d
	length += best
	precalculated_distance_to_end = length
	return length

func get_distance_to_start() -> float:
	if precalculated_distance_to_start != -1.0:
		return precalculated_distance_to_start
	var length = 0.0 if transition_type == OVERPASS else tile_length
	var best = 0.0
	var last = 0.0
	for prev in previous_tiles:
		last = prev.get_distance_to_start()
		if last > best:
			best = last
	
	length += last
	precalculated_distance_to_start = length
	return length

func update_bloon_position(_bloon) -> void:
	push_error("update_bloon_position not implemented in base Tile class")

func get_all_previous_tiles(_result: Array[Tile]) -> void:
	pass
