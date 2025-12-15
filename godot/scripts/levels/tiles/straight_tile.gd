class_name StraightTile
extends Tile

var section_length: float = 0.0

func _init():
	pass

func setup(start: Vector2, end: Vector2):
	way_points = [start, end]
	var delta = end - start
	section_length = delta.length()
	tile_length = section_length

func update_bloon_position(bloon) -> void:
	if way_points.size() < 2:
		return
	
	var progress_ratio = bloon.tile_progress / tile_length
	
	if progress_ratio >= 1.0:
		if next_tiles.size() > 0:
			bloon.tile = next_tiles[0]
			bloon.tile_progress = bloon.tile_progress - tile_length
			bloon.tile.update_bloon_position(bloon)
		else:
			bloon.destroy()
		return
	
	var start_pos = way_points[0]
	var end_pos = way_points[1]
	bloon.position = start_pos.lerp(end_pos, progress_ratio)

func get_all_previous_tiles(_result: Array[Tile]) -> void:
	pass
