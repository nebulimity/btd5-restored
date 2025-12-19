extends Node

var assets = {}

func preload_all() -> void:
	assets = {
		"Dart": load_animation("res://assets/projectiles/dart"),
		"Tack": load_animation("res://assets/projectiles/tack"),
		"Boomerang": load_animation("res://assets/projectiles/boomerang"),
		"Shuriken": load_animation("res://assets/projectiles/shuriken"),
		"Bomb": load_animation("res://assets/projectiles/bomb"),
		"MediumExplosion": load_animation("res://assets/projectiles/medium_explosion"),
		"NormalBloon": load_animation("res://assets/sprites/bloons/normal"),
		"RegenBloon": load_animation("res://assets/sprites/bloons/regen"),
		"CamoOverlay": load_animation("res://assets/sprites/bloons/camo_overlay"),
		"Burst": preload("res://assets/sprites/bloons/burst.svg"),
		"DartMonkey": load_animation("res://assets/sprites/towers/dart_monkey"),
		"TackShooter": load_animation("res://assets/sprites/towers/tack_shooter"),
		"SniperMonkey": load_animation("res://assets/sprites/towers/sniper_monkey"),
		"BoomerangThrower": load_animation("res://assets/sprites/towers/boomerang_thrower"),
		"NinjaMonkey": load_animation("res://assets/sprites/towers/ninja_monkey"),
		"BombTower": load_animation("res://assets/sprites/towers/bomb_tower"),
		"IceTower": load_animation("res://assets/sprites/towers/ice_tower"),
		"SuperMonkey": load_animation("res://assets/sprites/towers/super_monkey"),
	}

func load_animation(path: String) -> Array:
	var frames = []
	var frame_index = 1
	while true:
		var frame_path = path + "/" + str(frame_index) + ".svg"
		if ResourceLoader.exists(frame_path):
			var texture = load(frame_path)
			frames.append(texture)
			frame_index += 1
		else:
			break
	
	return frames

func grab(asset_name):
	return assets.get(asset_name)
