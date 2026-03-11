class_name ArchipelagoDef
extends LevelDef

func setup() -> void:
		id = "Archipelago"
		name = "Archipelago"
		music = "main_theme"
		difficulty = INTERMEDIATE
		scene_path = "res://scenes/maps/archipelago.tscn"
		
		var tiles: Array[Tile] = []
		
		var tile0 = StraightTile.new()
		tile0.setup(Vector2(-40,421), Vector2(7,421))
		tiles.append(tile0)
		
		var tile1 = StraightTile.new()
		tile1.setup(Vector2(7,421), Vector2(101,441))
		tiles.append(tile1)
		
		var tile2 = ArcTile.new()
		tile2.setup_from_three_points(Vector2(107.73451327433628,409.3477876106195), Vector2(101,441), Vector2(139,401), false)
		tiles.append(tile2)
		
		var tile3 = ArcTile.new()
		tile3.setup_from_three_points(Vector2(480.3439089709227,309.86223907945873), Vector2(139,401), Vector2(129,347), false)
		tiles.append(tile3)
		
		var tile4 = ArcTile.new()
		tile4.setup_from_three_points(Vector2(189.73922398145837,340.5797413271528), Vector2(129,347), Vector2(145,299), false)
		tiles.append(tile4)
		
		var tile5 = ArcTile.new()
		tile5.setup_from_three_points(Vector2(-1.2863601611073818,163.04437820132065), Vector2(145,299), Vector2(183,240), false)
		tiles.append(tile5)
		
		var tile6 = ArcTile.new()
		tile6.setup_from_three_points(Vector2(102.4382059660819,206.35842746214425), Vector2(183,240), Vector2(189,195), false)
		tiles.append(tile6)
		
		var tile7 = ArcTile.new()
		tile7.setup_from_three_points(Vector2(426.1682331253848,163.87936297595627), Vector2(189,195), Vector2(200,86), false)
		tiles.append(tile7)
		
		var tile8 = ArcTile.new()
		tile8.setup_from_three_points(Vector2(229.52034817749652,96.16511416798888), Vector2(200,86), Vector2(248,71), false)
		tiles.append(tile8)
		
		var tile9 = ArcTile.new()
		tile9.setup_from_three_points(Vector2(163.16749194627442,186.52272579774345), Vector2(248,71), Vector2(294,128), false)
		tiles.append(tile9)
		
		var tile10 = ArcTile.new()
		tile10.setup_from_three_points(Vector2(238.82282906015874,152.68131577728013), Vector2(294,128), Vector2(298,165), false)
		tiles.append(tile10)
		
		var tile11 = ArcTile.new()
		tile11.setup_from_three_points(Vector2(751.8158828546566,259.4691080589927), Vector2(298,165), Vector2(297,349), false)
		tiles.append(tile11)
		
		var tile12 = ArcTile.new()
		tile12.setup_from_three_points(Vector2(395.718043593164,329.5672694671667), Vector2(297,349), Vector2(361,424), false)
		tiles.append(tile12)
		
		var tile13 = ArcTile.new()
		tile13.setup_from_three_points(Vector2(382.76088832865446,364.8106018940674), Vector2(361,424), Vector2(441,389), false)
		tiles.append(tile13)
		
		var tile14 = ArcTile.new()
		tile14.setup_from_three_points(Vector2(356.484955661365,353.896991132273), Vector2(441,389), Vector2(448,354), false)
		tiles.append(tile14)
		
		var tile15 = ArcTile.new()
		tile15.setup_from_three_points(Vector2(748.2311410009303,354.3379386429236), Vector2(448,354), Vector2(451,312), false)
		tiles.append(tile15)
		
		var tile16 = ArcTile.new()
		tile16.setup_from_three_points(Vector2(519.0111552843824,321.68758559338005), Vector2(451,312), Vector2(485,262), false)
		tiles.append(tile16)
		
		var tile17 = StraightTile.new()
		tile17.setup(Vector2(485,262), Vector2(595,246))
		tiles.append(tile17)
		
		var tile18 = ArcTile.new()
		tile18.setup_from_three_points(Vector2(589.7662650602409,210.01807228915663), Vector2(595,246), Vector2(625,219), false)
		tiles.append(tile18)
		
		var tile19 = ArcTile.new()
		tile19.setup_from_three_points(Vector2(557.693645898729,201.84198913195956), Vector2(625,219), Vector2(599,146), false)
		tiles.append(tile19)
		
		var tile20 = ArcTile.new()
		tile20.setup_from_three_points(Vector2(2647.9227028093374,-2623.935081222372), Vector2(599,146), Vector2(546,106), false)
		tiles.append(tile20)
		
		var tile21 = ArcTile.new()
		tile21.setup_from_three_points(Vector2(576.7442498655627,66.06998442821478), Vector2(546,106), Vector2(527,58), false)
		tiles.append(tile21)
		
		var tile22 = StraightTile.new()
		tile22.setup(Vector2(527,58), Vector2(525,1))
		tiles.append(tile22)
		
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
		tile19.next_tiles.append(tile20)
		tile20.next_tiles.append(tile21)
		tile21.next_tiles.append(tile22)
		
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
		tile20.previous_tiles.append(tile19)
		tile21.previous_tiles.append(tile20)
		tile22.previous_tiles.append(tile21)
		
		
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
