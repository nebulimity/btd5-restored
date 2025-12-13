class_name Spread
extends Weapon

var angle: float = 0.0
var count: int = 1
var rotate: bool = true
var rand_rotate: bool = false
var offset: float = 0.0

func SetAngle(value: float) -> Spread:
	angle = value
	return self

func SetCount(value: int) -> Spread:
	count = value
	return self

func SetRange(value: float) -> Spread:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> Spread:
	reload_time = value
	return self

func SetPower(value: float) -> Spread:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> Spread:
	projectile = proj
	return self

func SetRotate(value: bool) -> Spread:
	rotate = value
	return self

func execute(tower: Tower, source: Node2D, target: Node2D, weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
	
	var base_angle = 0.0
	if target != null and rotate:
		var direction = target.global_position - source.global_position
		base_angle = direction.angle()
		tower.rotation = base_angle + deg_to_rad(90.0)
	elif not rotate:
		base_angle = source.rotation - deg_to_rad(90.0)
	else:
		base_angle = source.rotation - deg_to_rad(90.0)
	
	if rand_rotate:
		base_angle = randf() * TAU
	
	base_angle += offset
	
	var start_angle = base_angle - angle / 2.0
	var angle_step = 0.0
	if count > 1 and angle > 0:
		angle_step = angle / (count - 1)
	
	for i in range(count):
		var proj = Projectile.new()
		proj.initialize(projectile)
		proj.owner_tower = tower
		proj.position = source.global_position
		
		if weapon_offset != Vector2.ZERO:
			var rotated_offset = weapon_offset.rotated(tower.rotation - deg_to_rad(90.0))
			proj.position += rotated_offset
		
		proj.lifespan = weapon_range / power
		proj.target = target as Bloon
		var shot_angle = start_angle + angle_step * i
		proj.velocity = Vector2.RIGHT.rotated(shot_angle) * power
		proj.rotation = proj.velocity.angle()
		
		if tower.level:
			tower.level.add_projectile(proj)
