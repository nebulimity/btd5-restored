class_name ParkDef
extends LevelDef

func setup() -> void:
		id = "Park"
		name = "Park Path"
		music = "jazz"
		difficulty = BEGINNER
		scene_path = "res://scenes/maps/park.tscn"
		
		var tiles: Array[Tile] = []
		
		var tile0 = StraightTile.new()
		tile0.setup(Vector2(578,-40), Vector2(578,71))
		tiles.append(tile0)
		
		var tile1 = ArcTile.new()
		tile1.setup_from_three_points(Vector2(524.565934065934,71), Vector2(578,71), Vector2(487,109), false)
		tiles.append(tile1)
		
		var tile2 = ArcTile.new()
		tile2.setup_from_three_points(Vector2(346.90544224081157,250.7133189209519), Vector2(487,109), Vector2(433,71), false)
		tiles.append(tile2)
		
		var tile3 = ArcTile.new()
		tile3.setup_from_three_points(Vector2(329.4554326012317,287.1383756162087), Vector2(433,71), Vector2(253,60), false)
		tiles.append(tile3)
		
		var tile4 = ArcTile.new()
		tile4.setup_from_three_points(Vector2(319.51899263449553,257.6186049908305), Vector2(253,60), Vector2(115,217), false)
		tiles.append(tile4)
		
		var tile5 = ArcTile.new()
		tile5.setup_from_three_points(Vector2(345.8481904233299,262.84772953781754), Vector2(115,217), Vector2(168,417), false)
		tiles.append(tile5)
		
		var tile6 = ArcTile.new()
		tile6.setup_from_three_points(Vector2(308.765290188988,294.9898236060209), Vector2(168,417), Vector2(274,478), false)
		tiles.append(tile6)
		
		var tile7 = ArcTile.new()
		tile7.setup_from_three_points(Vector2(324.7290420254195,210.95402170092302), Vector2(274,478), Vector2(424,464), false)
		tiles.append(tile7)
		
		var tile8 = ArcTile.new()
		tile8.setup_from_three_points(Vector2(373.5791507608746,335.4750680087947), Vector2(424,464), Vector2(485,417), false)
		tiles.append(tile8)
		
		var tile9 = ArcTile.new()
		tile9.setup_from_three_points(Vector2(453.60124804498196,394.02601321725786), Vector2(485,417), Vector2(423,370), false)
		tiles.append(tile9)
		
		var tile10 = ArcTile.new()
		tile10.setup_from_three_points(Vector2(356.85221756077294,318.0652719509661), Vector2(423,370), Vector2(393,394), false)
		tiles.append(tile10)
		
		var tile11 = ArcTile.new()
		tile11.setup_from_three_points(Vector2(329.70193869595295,261.03137103265504), Vector2(393,394), Vector2(218,357), false)
		tiles.append(tile11)
		
		var tile12 = ArcTile.new()
		tile12.setup_from_three_points(Vector2(323.5675718507132,266.30170727384444), Vector2(218,357), Vector2(195,213), false)
		tiles.append(tile12)
		
		var tile13 = ArcTile.new()
		tile13.setup_from_three_points(Vector2(329.82859258192286,268.8974092027719), Vector2(195,213), Vector2(282,131), false)
		tiles.append(tile13)
		
		var tile14 = ArcTile.new()
		tile14.setup_from_three_points(Vector2(320.44148053602197,241.8328781106503), Vector2(282,131), Vector2(339,126), false)
		tiles.append(tile14)
		
		var tile15 = ArcTile.new()
		tile15.setup_from_three_points(Vector2(333.79822187193747,158.46686423645139), Vector2(339,126), Vector2(346,189), false)
		tiles.append(tile15)
		
		var tile16 = ArcTile.new()
		tile16.setup_from_three_points(Vector2(300.5954925893616,75.3819703574462), Vector2(346,189), Vector2(314,197), false)
		tiles.append(tile16)
		
		var tile17 = ArcTile.new()
		tile17.setup_from_three_points(Vector2(321.6320566572771,266.24504305482486), Vector2(314,197), Vector2(275,318), false)
		tiles.append(tile17)
		
		var tile18 = ArcTile.new()
		tile18.setup_from_three_points(Vector2(331.19662891014275,255.62972688328662), Vector2(275,318), Vector2(372,329), false)
		tiles.append(tile18)
		
		var tile19 = ArcTile.new()
		tile19.setup_from_three_points(Vector2(346.19157796289124,282.59278111104965), Vector2(372,329), Vector2(396,301), false)
		tiles.append(tile19)
		
		var tile20 = ArcTile.new()
		tile20.setup_from_three_points(Vector2(434.7638701386341,315.3255902002493), Vector2(396,301), Vector2(435,274), false)
		tiles.append(tile20)
		
		var tile21 = ArcTile.new()
		tile21.setup_from_three_points(Vector2(523.6263865849595,-15236.692767754641), Vector2(435,274), Vector2(788,272), false)
		tiles.append(tile21)
		
		var tile22 = StraightTile.new()
		tile22.setup(Vector2(788,272), Vector2(799,274))
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
