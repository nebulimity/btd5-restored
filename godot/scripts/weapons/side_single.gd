class_name SideSingle
extends Weapon

var fire_from_right: String = ""
var fire_from_left: String = ""

func SetRange(value: float) -> SideSingle:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> SideSingle:
	reload_time = value
	return self

func SetPower(value: float) -> SideSingle:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> SideSingle:
	projectile = proj
	return self

func SetFireFromRight(value: String) -> SideSingle:
	fire_from_right = value
	return self

func SetFireFromLeft(value: String) -> SideSingle:
	fire_from_left = value
	return self

func execute(tower: Tower, source: Node2D, target: Node2D, _weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
	
	var proj = Pool.get_obj(AssetManager.grab("projectile")) as Projectile
	proj.initialize(projectile)
	proj.owner_tower = tower
	proj.position = source.global_position
	proj.lifespan = weapon_range / power
	
	var fire_side = ""
	var spawn_offset = Vector2.ZERO
	
	if target != null:
		var direction = target.global_position - proj.position
		proj.velocity = direction.normalized() * power
		
		var tower_forward = Vector2(1.0, 0.0).rotated(tower.rotation)
		var angle = rad_to_deg(tower_forward.angle_to(direction))
		
		if angle < -180.0:
			tower.rotation = direction.angle()
			fire_side = fire_from_left
		else:
			tower.rotation = direction.angle() - deg_to_rad(180.0)
			fire_side = fire_from_right
		
		var clip = tower.tower_def.display_addons[0].clip
		if clip == "BuccaneerCannonsLeft" or clip == "BuccaneerCannonsRight" or clip == "LongerCannonsLeft" or clip == "LongerCannonsRight":
			spawn_offset.x = 7.0
			spawn_offset.y = -60.0 if fire_side == fire_from_left else 60.0
			spawn_offset = spawn_offset.rotated(tower.rotation + deg_to_rad(90.0))
		elif clip == "LeftBack" or clip == "RightBack" or clip == "LeftFront" or clip == "RightFront":
			spawn_offset.x = 0.0
			spawn_offset.y = -70.0 if fire_side == fire_from_left else 70.0
			spawn_offset = spawn_offset.rotated(tower.rotation + deg_to_rad(90.0))
		elif clip == "CannonShipCannonsLeft" or clip == "CannonShipCannonsRight" or clip == "PiratesCannonsLeft" or clip == "PiratesCannonsRight":
			spawn_offset.x = 0.0
			spawn_offset.y = -70.0 if fire_side == fire_from_left else 70.0
			spawn_offset = spawn_offset.rotated(tower.rotation + deg_to_rad(90.0))
	else:
		var shoot_angle = tower.rotation - deg_to_rad(180.0)
		proj.velocity = Vector2(cos(shoot_angle), sin(shoot_angle)) * power
	
	proj.position = source.global_position + spawn_offset
	proj.rotation = proj.velocity.angle()
	proj.target = target as Bloon
	
	var anim_side = fire_from_right if fire_side == fire_from_left else fire_from_left
	for i in tower.addon_clips.size():
		if tower.tower_def.display_addons[i].ref == anim_side:
			tower.addon_clips[i].play("default")
	
	if tower.level:
		tower.level.add_projectile(proj)
