class_name LevelDef
extends RefCounted

const BEGINNER: int = 1
const INTERMEDIATE: int = 2
const ADVANCED: int = 3
const EXPERT: int = 4
const EXTREME: int = 5

var id: String = ""
var name: String = ""
var difficulty: int = BEGINNER
var scene_path: String = ""
var music: String = "main_theme"

var tile_sets: Array[Array] = []

func setup() -> void:
	pass

func get_start_tile() -> Tile:
	if tile_sets.size() > 0 and tile_sets[0].size() > 0:
		return tile_sets[0][0]
	return null

func get_path_length() -> float:
	var total_length = 0.0
	if tile_sets.size() > 0:
		for tile in tile_sets[0]:
			total_length += tile.tile_length
	return total_length
