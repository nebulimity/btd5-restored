extends Node

var assets = {}

func preload_all() -> void:
	assets = {
		"Dart": load_animation("res://assets/projectiles/dart/"),
		"Tack": load_animation("res://assets/projectiles/tack/"),
		"Boomerang": load_animation("res://assets/projectiles/boomerang/"),
		"Shuriken": load_animation("res://assets/projectiles/shuriken/"),
		"Bomb": load_animation("res://assets/projectiles/bomb/"),
		"MediumExplosion": load_animation("res://assets/projectiles/medium_explosion/"),
		"IceBurst": load_animation("res://assets/projectiles/ice_burst/"),
		"GlueShot": load_animation("res://assets/projectiles/glue_shot/"),
		"BuccaneerDart": load_animation("res://assets/projectiles/buccaneer_dart/"),
		"NormalBloon": load_animation("res://assets/bloons/normal/"),
		"RegenBloon": load_animation("res://assets/bloons/regen/"),
		"CamoEffect": load_animation("res://assets/bloons/camo_effect/"),
		"IceEffect": load_animation("res://assets/bloons/ice_effect/"),
		"GlueEffect": load_animation("res://assets/bloons/glue_effect/"),
		"Burst": preload("res://assets/bloons/burst.svg/"),
		"DartMonkey": load_animation("res://assets/towers/dart_monkey/"),
		"TackShooter": load_animation("res://assets/towers/tack_shooter/"),
		"SniperMonkey": load_animation("res://assets/towers/sniper_monkey/"),
		"BoomerangThrower": load_animation("res://assets/towers/boomerang_thrower/"),
		"NinjaMonkey": load_animation("res://assets/towers/ninja_monkey/"),
		"BombTower": load_animation("res://assets/towers/bomb_tower/"),
		"IceTower": load_animation("res://assets/towers/ice_tower/"),
		"GlueGunner": load_animation("res://assets/towers/glue_gunner/"),
		"MonkeyBuccaneer": load_animation("res://assets/towers/monkey_buccaneer/"),
		"BuccaneerCannonsRight": load_animation("res://assets/towers/buccaneer_cannons_right/"),
		"BuccaneerCannonsLeft": load_animation("res://assets/towers/buccaneer_cannons_left/"),
		"SuperMonkey": load_animation("res://assets/towers/super_monkey/"),
		"SnowFlakes": load_animation("res://assets/towers/snow_flakes/"),
	}

func load_animation(path: String) -> Array:
	var frames = []
	var frame_index = 1
	while true:
		var frame_path = path + str(frame_index) + ".svg"
		if ResourceLoader.exists(frame_path):
			var texture = load(frame_path)
			frames.append(texture)
			frame_index += 1
		else:
			break
	
	return frames

func grab(asset_name):
	return assets.get(asset_name)
