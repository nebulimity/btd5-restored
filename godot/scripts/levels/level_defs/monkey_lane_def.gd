class_name MonkeyLaneDef
extends RefCounted

var tile_sets: Array[Array] = []

func parse_monkey_lane() -> void:
	var tiles: Array[Tile] = []
	
	var tile0 = StraightTile.new()
	tile0.setup(Vector2(-100, 305), Vector2(134, 305))
	tiles.append(tile0)
	
	var tile1 = ArcTile.new()
	tile1.setup_from_three_points(Vector2(134, 269.25581395348837), Vector2(134, 305), Vector2(169, 262), false)
	tiles.append(tile1)
	
	var tile2 = ArcTile.new()
	tile2.setup_from_three_points(Vector2(201.99687390235334, 255.1594520547945), Vector2(169, 262), Vector2(208, 222), false)
	tiles.append(tile2)
	
	var tile3 = StraightTile.new()
	tile3.setup(Vector2(208, 222), Vector2(256, 221))
	tiles.append(tile3)
	
	var tile4 = ArcTile.new()
	tile4.setup_from_three_points(Vector2(256.64824797843664, 252.11590296495956), Vector2(256, 221), Vector2(287, 259), false)
	tiles.append(tile4)
	
	var tile5 = StraightTile.new()
	tile5.setup(Vector2(287, 259), Vector2(285, 463))
	tiles.append(tile5)
	
	var tile6 = ArcTile.new()
	tile6.setup_from_three_points(Vector2(313.7711103126123, 463.2820697089472), Vector2(285, 463), Vector2(312, 492), false)
	tiles.append(tile6)
	
	var tile7 = StraightTile.new()
	tile7.setup(Vector2(312, 492), Vector2(420, 493))
	tiles.append(tile7)
	
	var tile8 = ArcTile.new()
	tile8.setup_from_three_points(Vector2(420.29427645788337, 461.2181425485961), Vector2(420, 493), Vector2(452, 459), false)
	tiles.append(tile8)
	
	var tile9 = StraightTile.new()
	tile9.setup(Vector2(452, 459), Vector2(453, 310))
	tiles.append(tile9)
	
	var tile10 = StraightTile.new()
	tile10.setup(Vector2(453, 310), Vector2(454, 281))
	tiles.append(tile10)
	
	var tile11 = StraightTile.new()
	tile11.setup(Vector2(454, 281), Vector2(454, 172))
	tiles.append(tile11)
	
	var tile12 = ArcTile.new()
	tile12.setup_from_three_points(Vector2(427.31944444444446, 172), Vector2(454, 172), Vector2(418, 147), false)
	tiles.append(tile12)
	
	var tile13 = StraightTile.new()
	tile13.setup(Vector2(418, 147), Vector2(202, 143))
	tiles.append(tile13)
	
	var tile14 = ArcTile.new()
	tile14.setup_from_three_points(Vector2(202.66470588235293, 107.10588235294118), Vector2(202, 143), Vector2(167, 103), false)
	tiles.append(tile14)
	
	var tile15 = StraightTile.new()
	tile15.setup(Vector2(167, 103), Vector2(165, 87))
	tiles.append(tile15)
	
	var tile16 = ArcTile.new()
	tile16.setup_from_three_points(Vector2(188.47330960854092, 84.06583629893238), Vector2(165, 87), Vector2(197, 62), false)
	tiles.append(tile16)
	
	var tile17 = StraightTile.new()
	tile17.setup(Vector2(197, 62), Vector2(512, 61))
	tiles.append(tile17)
	
	var tile18 = ArcTile.new()
	tile18.setup_from_three_points(Vector2(512.1095861486486, 95.51963682432432), Vector2(512, 61), Vector2(545, 106), false)
	tiles.append(tile18)
	
	var tile19 = ArcTile.new()
	tile19.setup_from_three_points(Vector2(570.3024296742894, 114.06249059108907), Vector2(545, 106), Vector2(576, 140), false)
	tiles.append(tile19)
	
	var tile20 = StraightTile.new()
	tile20.setup(Vector2(576, 140), Vector2(613, 141))
	tiles.append(tile20)
	
	var tile21 = ArcTile.new()
	tile21.setup_from_three_points(Vector2(612.0833333333334, 174.91666666666666), Vector2(613, 141), Vector2(646, 174), false)
	tiles.append(tile21)
	
	var tile22 = StraightTile.new()
	tile22.setup(Vector2(646, 174), Vector2(645, 203))
	tiles.append(tile22)
	
	var tile23 = ArcTile.new()
	tile23.setup_from_three_points(Vector2(615.6367432150313, 201.9874739039666), Vector2(645, 203), Vector2(611, 231), false)
	tiles.append(tile23)
	
	var tile24 = StraightTile.new()
	tile24.setup(Vector2(611, 231), Vector2(569, 233))
	tiles.append(tile24)
	
	var tile25 = ArcTile.new()
	tile25.setup_from_three_points(Vector2(570.4037267080745, 262.47826086956525), Vector2(569, 233), Vector2(541, 265), false)
	tiles.append(tile25)
	
	var tile26 = StraightTile.new()
	tile26.setup(Vector2(541, 265), Vector2(538, 364))
	tiles.append(tile26)
	
	var tile27 = ArcTile.new()
	tile27.setup_from_three_points(Vector2(515.6401869158879, 363.3224299065421), Vector2(538, 364), Vector2(505, 383), false)
	tiles.append(tile27)
	
	var tile28 = StraightTile.new()
	tile28.setup(Vector2(505, 383), Vector2(395, 385))
	tiles.append(tile28)
	
	var tile29 = StraightTile.new()
	tile29.setup(Vector2(395, 385), Vector2(363, 383))
	tiles.append(tile29)
	
	var tile30 = StraightTile.new()
	tile30.setup(Vector2(363, 383), Vector2(206, 387))
	tiles.append(tile30)
	
	var tile31 = ArcTile.new()
	tile31.setup_from_three_points(Vector2(207.0966370313104, 430.04300347893314), Vector2(206, 387), Vector2(165, 421), false)
	tiles.append(tile31)
	
	var tile32 = StraightTile.new()
	tile32.setup(Vector2(165, 421), Vector2(164, 615))
	tiles.append(tile32)
	
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
	tile22.next_tiles.append(tile23)
	tile23.next_tiles.append(tile24)
	tile24.next_tiles.append(tile25)
	tile25.next_tiles.append(tile26)
	tile26.next_tiles.append(tile27)
	tile27.next_tiles.append(tile28)
	tile28.next_tiles.append(tile29)
	tile29.next_tiles.append(tile30)
	tile30.next_tiles.append(tile31)
	tile31.next_tiles.append(tile32)
	
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
