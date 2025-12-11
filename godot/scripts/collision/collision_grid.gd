class_name CollisionGrid
extends Node

const CELL_SIZE: int = 40
const OFFSET_X: int = 52
const OFFSET_Y: int = -60

var columns: int = 0
var rows: int = 0
var cells: Array[Array] = []

func _init(map_width: float = 700.0, map_height: float = 520.0) -> void:
	columns = ceil((map_width - OFFSET_X) / float(CELL_SIZE))
	rows = ceil((map_height - OFFSET_Y) / float(CELL_SIZE))
	
	cells.resize(columns * rows)
	for i in range(cells.size()):
		cells[i] = []

func get_cell_index(pos: Vector2) -> int:
	var c = floor((pos.x - OFFSET_X) / CELL_SIZE)
	var r = floor((pos.y - OFFSET_Y) / CELL_SIZE)
	if c < 0 or c >= columns or r < 0 or r >= rows:
		return -1
	return int(r * columns + c)

func add_bloon(bloon: Bloon) -> void:
	var idx = get_cell_index(bloon.global_position)
	if idx != -1:
		cells[idx].append(bloon)

func remove_bloon(bloon: Bloon, pos: Vector2) -> void:
	var idx = get_cell_index(pos)
	if idx != -1:
		cells[idx].erase(bloon)

func move_bloon(bloon: Bloon, old_pos: Vector2) -> void:
	var old_idx = get_cell_index(old_pos)
	var new_idx = get_cell_index(bloon.global_position)
	
	if old_idx == new_idx:
		return
		
	if old_idx != -1:
		cells[old_idx].erase(bloon)
	if new_idx != -1:
		cells[new_idx].append(bloon)

func get_bloons_in_range(pos: Vector2, radius: float) -> Array:
	var result = []
	
	var min_c = floor((pos.x - radius - OFFSET_X) / CELL_SIZE)
	var max_c = floor((pos.x + radius - OFFSET_X) / CELL_SIZE)
	var min_r = floor((pos.y - radius - OFFSET_Y) / CELL_SIZE)
	var max_r = floor((pos.y + radius - OFFSET_Y) / CELL_SIZE)
	
	min_c = max(0, min_c)
	max_c = min(columns - 1, max_c)
	min_r = max(0, min_r)
	max_r = min(rows - 1, max_r)
	
	for r in range(min_r, max_r + 1):
		for c in range(min_c, max_c + 1):
			var idx = r * columns + c
			result.append_array(cells[idx])
			
	return result
