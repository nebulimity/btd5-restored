class_name Tile
extends RefCounted

const NORMAL = 0
const UNDERPASS = 1
const OVERPASS = 2

var way_points: Array[Vector2] = []
var next_tiles: Array[Tile] = []
var previous_tile: Tile = null
var tile_length: float = 0.0
var transition_type: int = NORMAL
var is_wind: bool = false
var layer: int = 0

func update_bloon_position(_bloon) -> void:
	push_error("update_bloon_position not implemented in base Tile class")

func get_all_previous_tiles(_result: Array[Tile]) -> void:
	pass
