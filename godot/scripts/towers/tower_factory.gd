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
			"cost": 200,
			"range": 100,
			"occupied_space_radius": small,
			"position_offset": Vector2(-2.335, 3.335),
			"weapon_offset": Vector2(6, 9),
			"rotation_offset": -90.0,
			"fire_frame": 8,
			"sprite_path": "res://assets/sprites/towers/dart_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"TackShooter": {
			"label": "Tack Shooter",
			"description": "Shoots 8 tacks spread in all directions, each tack can pop 1 bloon. Has short range and medium-slow fire rate.",
			"cost": 360,
			"range": 70,
			"occupied_space_radius": small,
			"rotation_offset": 0.0,
			"rotates": false,
			"fire_frame": 5,
			"sprite_path": "res://assets/sprites/towers/tack_shooter/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"SniperMonkey": {
			"label": "Sniper Monkey",
			"description": "Armed with a high-tech long range rifle, pops 2 layers off of bloons with unlimited range.",
			"cost": 350,
			"range": 1200,
			"occupied_space_radius": small,
			"position_offset": Vector2(22.5, -3.5),
			"rotation_offset": -90.0,
			"rotates": false,  # instant class ignores this
			"fire_frame": 2,
			"sprite_path": "res://assets/sprites/towers/sniper_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BoomerangThrower": {
			"label": "Boomerang Thrower",
			"description": "hrows a single boomerang in an arc back round to the monkey. Each boomerang can pop 3 bloons.",
			"cost": 380,
			"range": 130,
			"occupied_space_radius": medium,
			"position_offset": Vector2(-3.0, 8.5),
			"weapon_offset": Vector2(26, 8),
			"rotation_offset": -90.0,
			"fire_frame": 10,
			"sprite_path": "res://assets/sprites/towers/boomerang_thrower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"NinjaMonkey": {
			"label": "Ninja Monkey",
			"description": "Stealthy tower that can see Camo Bloons and throws sharp shurikens rapidly.",
			"cost": 500,
			"range": 120,
			"occupied_space_radius": small,
			"weapon_offset": Vector2.ZERO,
			"rotation_offset": -90.0,
			"fire_frame": 3,
			"sprite_path": "res://assets/sprites/towers/ninja_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BombTower": {
			"label": "Bomb Tower",
			"description": "Shoots a single bomb that explodes in a radius burst on impact. Good range, medium-slow fire rate. Can pop lead bloons but not black bloons.",
			"cost": 650,
			"range": 120,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/bomb_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"IceTower": {
			"label": "Ice Tower",
			"description": "Freezes bloons in its burst radius for a short time. Frozen bloons are immune to sharp objects.",
			"cost": 300,
			"range": 60,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/ice_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"GlueTower": {
			"label": "Glue Gunner",
			"description": "Shoots a glob of monkey glue at a single bloon. Glued bloons move more slowly than normal.",
			"cost": 270,
			"range": 140,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/glue_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BuccaneerTower": {
			"label": "Monkey Buccaneer",
			"description": "Monkey Buccaneers can only be placed on water. Shoots a single, heavy dart that can pop up to 5 bloons each.",
			"cost": 500,
			"range": 180,
			"occupied_space_radius": medium,
			"sprite_path": "res://assets/sprites/towers/buccaneer_tower/1.svg",
			"can_place_on_water": true,
			"can_place_on_track": false,
			"requires_water": true
		},
		"MonkeyAce": {
			"label": "Monkey Ace",
			"description": "Patrols the skies above the action, regularly strafing the area with powerful darts in 8 directions.",
			"cost": 900,
			"range": 50, 
			"occupied_space_radius": "ace_space",
			"sprite_path": "res://assets/sprites/towers/monkey_ace/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": true,  # Runway
			"requires_track": true
		},
		"SuperMonkey": {
			"label": "Super Monkey",
			"description": "Throws darts incredibly fast. Has long range and lots of insanely powerful upgrades.",
			"cost": 3500,
			"range": 140,
			"occupied_space_radius": large,
			"position_offset": Vector2(-1.0, 1.5),
			"weapon_offset": Vector2(9, 14),
			"rotation_offset": -90.0,
			"idle_frame": 1,
			"fire_frame": 2,
			"sprite_path": "res://assets/sprites/towers/super_monkey/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MonkeyApprentice": {
			"label": "Monkey Apprentice",
			"description": "Trained in the arts of monkey magic, the Monkey Apprentice weaves magical bolts of power that pop bloons. Each shot can pop 2 bloons. Can upgrade to cast additional spells.",
			"cost": 550,
			"range": 120,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/monkey_apprentice/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MonkeyVillage": {
			"label": "Monkey Village",
			"description": "Monkey Village does not attack bloons but instead lowers cost of all towers and upgrades in radius by 10%. Has many useful upgrades that help nearby towers.",
			"cost": 1600,
			"range": 120,
			"occupied_space_radius": "village_space",
			"sprite_path": "res://assets/sprites/towers/monkey_village/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"BananaTower": {
			"label": "Banana Farm",
			"description": "Banana Farms grow bananas that you can collect to turn into cash. When your farm produces some bananas, collect them by moving your mouse over them. Don't leave them too long however, or they will spoil!",
			"cost": 1000,
			"range": 120,
			"occupied_space_radius": "banana_farm_space",
			"sprite_path": "res://assets/sprites/towers/banana_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"MortarTower": {
			"label": "Mortar Tower",
			"description": "Targets a specific bit of ground anywhere on the screen. Launches explosive mortar shells to that spot. Useful for placing far away from the track to make room for other towers.",
			"cost": 750,
			"range": 1250,  # Manual targeting
			"occupied_space_radius": "mortar_monkey_space",
			"sprite_path": "res://assets/sprites/towers/mortar_tower/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"DartlingGun": {
			"label": "Dartling Gun",
			"description": "Shoots darts like a machine gun, super fast but not very accurate. The Dartling Gun will shoot towards wherever your mouse is, so you control how effective it is!",
			"cost": 950,
			"range": 1250,  # Manual aiming
			"occupied_space_radius": large,
			"sprite_path": "res://assets/sprites/towers/dartling_gun/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"SpikeFactory": {
			"label": "Spike Factory",
			"description": "Generates piles of road spikes on bits of nearby track. Each pile can pop 5 bloons, and unused spikes disappear at the end of each round.",
			"cost": 750,
			"range": 105,
			"occupied_space_radius": large,
			"sprite_path": "res://assets/sprites/towers/spike_factory/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		},
		"RoadSpikes": {
			"label": "Road Spikes",
			"description": "Place these on the track to pop bloons. Each pack of spikes can pop 11 bloons before being used up. Use these to get bloons that escape past your towers.",
			"cost": 30,
			"range": 20,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/road_spikes/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": true,
			"requires_track": true
		},
		"ExplodingPineapple": {
			"label": "Exploding Pineapple",
			"description": "This explosive fruit packs a real punch. When placed will explode violently after 3 seconds. Useful for destroying those bloons that require explosives to pop.",
			"cost": 25,
			"range": 100,
			"occupied_space_radius": small,
			"sprite_path": "res://assets/sprites/towers/exploding_pineapple/1.svg",
			"can_place_on_water": false,
			"can_place_on_track": false
		}
	}
	
	return defs.get(tower_type, {})
