class_name RinkDef
extends LevelDef

func setup() -> void:
		id = "Rink"
		name = "The Rink"
		music = "dance"
		difficulty = BEGINNER
		scene_path = "res://scenes/maps/rink.tscn"
		
		var tiles: Array[Tile] = []
		
		var tile0 = StraightTile.new()
		tile0.setup(Vector2(432,640), Vector2(432,304))
		tiles.append(tile0)
		
		var tile1 = ArcTile.new()
		tile1.setup_from_three_points(Vector2(9458,304), Vector2(432,304), Vector2(434,114), false)
		tiles.append(tile1)
		
		var tile2 = ArcTile.new()
		tile2.setup_from_three_points(Vector2(516.7858781065534,115.74305372786405), Vector2(434,114), Vector2(530,34), false)
		tiles.append(tile2)
		
		var tile3 = ArcTile.new()
		tile3.setup_from_three_points(Vector2(513.3460786442874,137.02178223698456), Vector2(530,34), Vector2(606,89), false)
		tiles.append(tile3)
		
		var tile4 = ArcTile.new()
		tile4.setup_from_three_points(Vector2(562.8010926932371,111.38964621472165), Vector2(606,89), Vector2(597,146), false)
		tiles.append(tile4)
		
		var tile5 = ArcTile.new()
		tile5.setup_from_three_points(Vector2(508.3189024037763,56.251981610384746), Vector2(597,146), Vector2(498,182), false)
		tiles.append(tile5)
		
		var tile6 = StraightTile.new()
		tile6.setup(Vector2(498,182), Vector2(165,184))
		tiles.append(tile6)
		
		var tile7 = ArcTile.new()
		tile7.setup_from_three_points(Vector2(164.38526680950923,81.64692378328742), Vector2(165,184), Vector2(93,155), false)
		tiles.append(tile7)
		
		var tile8 = ArcTile.new()
		tile8.setup_from_three_points(Vector2(137.84472750457405,108.9190807629995), Vector2(93,155), Vector2(79,83), false)
		tiles.append(tile8)
		
		var tile9 = ArcTile.new()
		tile9.setup_from_three_points(Vector2(159.87564737861953,118.62294406076342), Vector2(79,83), Vector2(126,37), false)
		tiles.append(tile9)
		
		var tile10 = ArcTile.new()
		tile10.setup_from_three_points(Vector2(160.811891595964,120.87881266529233), Vector2(126,37), Vector2(220,52), false)
		tiles.append(tile10)
		
		var tile11 = ArcTile.new()
		tile11.setup_from_three_points(Vector2(148.30626726497678,135.43194806331184), Vector2(220,52), Vector2(251,96), false)
		tiles.append(tile11)
		
		var tile12 = StraightTile.new()
		tile12.setup(Vector2(251,96), Vector2(251,378))
		tiles.append(tile12)
		
		var tile13 = ArcTile.new()
		tile13.setup_from_three_points(Vector2(82,378), Vector2(251,378), Vector2(238,443), false)
		tiles.append(tile13)
		
		var tile14 = ArcTile.new()
		tile14.setup_from_three_points(Vector2(197.93364928909955,426.3056872037915), Vector2(238,443), Vector2(210,468), false)
		tiles.append(tile14)
		
		var tile15 = ArcTile.new()
		tile15.setup_from_three_points(Vector2(162,302.1398271798898), Vector2(210,468), Vector2(114,468), false)
		tiles.append(tile15)
		
		var tile16 = ArcTile.new()
		tile16.setup_from_three_points(Vector2(130.59205531844077,410.6674757800538), Vector2(114,468), Vector2(73,395), false)
		tiles.append(tile16)
		
		var tile17 = ArcTile.new()
		tile17.setup_from_three_points(Vector2(155.52327637227677,417.4498227525375), Vector2(73,395), Vector2(152,332), false)
		tiles.append(tile17)
		
		var tile18 = ArcTile.new()
		tile18.setup_from_three_points(Vector2(187,1180.8530221108288), Vector2(152,332), Vector2(222,332), false)
		tiles.append(tile18)
		
		var tile19 = StraightTile.new()
		tile19.setup(Vector2(222,332), Vector2(798,333))
		tiles.append(tile19)
		
		tile0.next_tiles.append(tile1)
		tile1.next_tiles.append(tile2)
		tile2.next_tiles.append(tile3)
		tile3.next_tiles.append(tile4)
		tile4.next_tiles.append(tile5)
		tile5.next_tiles.append(tile6)
		tile6.next_tiles.append(tile7)
		tile7.next_tiles.append(tile8)
		tile8.next_tiles.append(tile9)
		tile9.next_tiles.append(tile10)
		tile10.next_tiles.append(tile11)
		tile11.next_tiles.append(tile12)
		tile12.next_tiles.append(tile13)
		tile13.next_tiles.append(tile14)
		tile14.next_tiles.append(tile15)
		tile15.next_tiles.append(tile16)
		tile16.next_tiles.append(tile17)
		tile17.next_tiles.append(tile18)
		tile18.next_tiles.append(tile19)
		
		tile1.previous_tiles.append(tile0)
		tile2.previous_tiles.append(tile1)
		tile3.previous_tiles.append(tile2)
		tile4.previous_tiles.append(tile3)
		tile5.previous_tiles.append(tile4)
		tile6.previous_tiles.append(tile5)
		tile7.previous_tiles.append(tile6)
		tile8.previous_tiles.append(tile7)
		tile9.previous_tiles.append(tile8)
		tile10.previous_tiles.append(tile9)
		tile11.previous_tiles.append(tile10)
		tile12.previous_tiles.append(tile11)
		tile13.previous_tiles.append(tile12)
		tile14.previous_tiles.append(tile13)
		tile15.previous_tiles.append(tile14)
		tile16.previous_tiles.append(tile15)
		tile17.previous_tiles.append(tile16)
		tile18.previous_tiles.append(tile17)
		tile19.previous_tiles.append(tile18)
		
		
		tile_sets.append(tiles)

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
