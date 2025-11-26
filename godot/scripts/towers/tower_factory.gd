class_name TowerFactory
extends Node

static func get_tower_def(tower_type: String) -> Dictionary:
	var small: float = 23.999 / 2
	var medium: float = 29.996 / 2
	var large: float = 38.002 / 2

	var defs = {
		"DartMonkey": {
			"label": "Dart Monkey",
			"description": "Shoots a single dart that pops a single bloon. A good, cheap tower suitable for the early rounds.",
			"cost": 170,
			"range": 100,
			"occupied_space_radius": small,
			"position_offset": Vector2(-2.335, 3.335),
			"weapon_offset": Vector2(6, 9),
			"sprite_path": "res://assets/sprites/towers/dart_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"TackShooter": {
			"label": "Tack Shooter",
			"description": "Shoots 8 tacks in all directions. Can pop many bloons at once but has a short range.",
			"cost": 280,
			"range": 65,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/tack_shooter/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"SniperMonkey": {
			"label": "Sniper Monkey",
			"description": "Accurate sniper that can target any bloon on screen. Slow rate of fire.",
			"cost": 350,
			"range": 999999,  # Infinite range
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/sniper_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BoomerangThrower": {
			"label": "Boomerang Thrower",
			"description": "Throws a boomerang that can pop multiple bloons per throw.",
			"cost": 330,
			"range": 75,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/boomerang_thrower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"NinjaMonkey": {
			"label": "Ninja Monkey",
			"description": "Throws shurikens rapidly. Can see and pop camo bloons.",
			"cost": 500,
			"range": 75,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/ninja_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BombTower": {
			"label": "Bomb Tower",
			"description": "Launches explosive bombs that deal area damage to many bloons.",
			"cost": 525,
			"range": 85,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/bomb_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"IceTower": {
			"label": "Ice Tower",
			"description": "Freezes nearby bloons in place. Cannot pop frozen bloons.",
			"cost": 300,
			"range": 75,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/ice_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"GlueTower": {
			"label": "Glue Gunner",
			"description": "Slows down bloons by covering them in sticky glue.",
			"cost": 275,
			"range": 75,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/glue_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BuccaneerTower": {
			"label": "Monkey Buccaneer",
			"description": "Naval tower that shoots darts from both sides. Can only be placed in water.",
			"cost": 500,
			"range": 80,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/buccaneer_tower/1.svg",
			"can_place_on_water": true,
			"can_place_on_track": false,
			"requires_water": true
		},
		"MonkeyAce": {
			"label": "Monkey Ace",
			"description": "Flies around the map shooting darts in 8 directions.",
			"cost": 800,
			"range": 0,  # Flies around map
			"occupied_space_radius": large,
			"sprite_path": "res://assets/sprites/towers/monkey_ace/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": true,  # Runway
			"requires_track": true
		},
		"SuperMonkey": {
			"label": "Super Monkey",
			"description": "Incredibly fast firing tower that pops many bloons. Very expensive.",
			"cost": 3500,
			"range": 100,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/super_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MonkeyApprentice": {
			"label": "Monkey Apprentice",
			"description": "Uses magic to shoot powerful bolts and create special effects.",
			"cost": 650,
			"range": 75,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/monkey_apprentice/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MonkeyVillage": {
			"label": "Monkey Village",
			"description": "Increases the range and attack speed of nearby towers.",
			"cost": 1200,
			"range": 100,
			"occupied_space_radius": large,
			"sprite_path": "res://assets/sprites/towers/monkey_village/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BananaTower": {
			"label": "Banana Farm",
			"description": "Produces extra cash each round. Does not pop bloons.",
			"cost": 850,
			"range": 0,
			"occupied_space_radius": large,
			"sprite_path": "res://assets/sprites/towers/banana_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MortarTower": {
			"label": "Mortar Tower",
			"description": "Launches explosive shells to any location on screen.",
			"cost": 650,
			"range": 999999,  # Manual targeting
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/mortar_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"DartlingGun": {
			"label": "Dartling Gun",
			"description": "Manually controlled tower that shoots where you point your mouse.",
			"cost": 800,
			"range": 999999,  # Manual aiming
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/dartling_gun/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"SpikeFactory": {
			"label": "Spike Factory",
			"description": "Generates piles of spikes that pop bloons that run over them.",
			"cost": 700,
			"range": 0,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/spike_factory/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"RoadSpikes": {
			"label": "Road Spikes",
			"description": "Single-use spike pile that pops up to 10 bloons. Must be placed on track.",
			"cost": 25,
			"range": 0,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/road_spikes/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": true,
			"requires_track": true
		},
		"ExplodingPineapple": {
			"label": "Exploding Pineapple",
			"description": "Single-use explosive that damages all nearby bloons.",
			"cost": 20,
			"range": 50,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/exploding_pineapple/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		}
	}
	
	return defs.get(tower_type, {})
