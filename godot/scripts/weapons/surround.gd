class_name Surround
extends Weapon

var lifespan: float = 0.0

func SetLifespan(value: float) -> Surround:
	lifespan = value
	return self

func SetRange(value: float) -> Surround:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> Surround:
	reload_time = value
	return self

func SetPower(value: float) -> Surround:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> Surround:
	projectile = proj
	return self

func execute(tower: Tower, source: Node2D, _target: Node2D, _weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
	
	var proj = preload("res://scenes/entities/projectile.tscn").instantiate() as Projectile
	proj.initialize(projectile)
	proj.owner_tower = tower
	proj.position = source.global_position
	proj.lifespan = lifespan
		
	if tower.level:
		tower.level.add_projectile(proj)
