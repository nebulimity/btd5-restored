class_name Circular
extends Weapon

var angle: float = 0.0
var count: int = 1
var offset: float = 0.0

func SetAngle(value: float) -> Circular:
	angle = value
	return self

func SetCount(value: int) -> Circular:
	count = value
	return self

func SetRange(value: float) -> Circular:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> Circular:
	reload_time = value
	return self

func SetPower(value: float) -> Circular:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> Circular:
	projectile = proj
	return self

func execute(tower: Tower, source: Node2D, _target: Node2D, _weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
		
	var rotation_offset: float = 2.0 * PI / count
	
	for i in range(count):
		var proj = Projectile.new()
		proj.initialize(projectile)
		proj.owner_tower = tower
		proj.position = source.global_position
		
		proj.lifespan = weapon_range / power
		proj.max_lifespan = proj.lifespan
		proj.velocity.x = power
		proj.velocity.y = 0
		proj.velocity = proj.velocity.rotated(source.rotation + rotation_offset * i)
		proj.rotation = proj.velocity.angle()
		
		if tower.level:
			tower.level.add_projectile(proj)
	
	reload_timer = reload_time
