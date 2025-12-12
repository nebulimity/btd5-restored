class_name Single
extends Weapon

var rotate: bool = true
var offset_sequence: Array[Vector2] = []
var offset_index: int = 0

func SetRange(value: float) -> Single:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> Single:
	reload_time = value
	return self

func SetPower(value: float) -> Single:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> Single:
	projectile = proj
	return self

func SetRotate(value: bool) -> Single:
	rotate = value
	return self

func execute(tower: Tower, source: Node2D, target: Node2D, weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
	
	var proj = Projectile.new()
	proj.initialize(projectile)
	proj.owner_tower = tower
	proj.position = source.global_position
	
	if rotate and target != null:
		var initial_direction = target.global_position - proj.position
		tower.rotation = initial_direction.angle() + deg_to_rad(90.0)
	
	var temp_rotation = Vector2.ZERO
	if offset_sequence.size() > 0:
		var seq_offset = offset_sequence[offset_index % offset_sequence.size()]
		temp_rotation = seq_offset
		offset_index += 1
	
	if weapon_offset != Vector2.ZERO:
		temp_rotation += weapon_offset
		temp_rotation = temp_rotation.rotated(tower.rotation - deg_to_rad(90.0))
		proj.position += temp_rotation
	
	proj.lifespan = weapon_range / power
	proj.max_lifespan = proj.lifespan
	proj.target = target as Bloon
	
	if target != null:
		proj.velocity = (target.global_position - proj.position).normalized() * power
	else:
		var shoot_angle = tower.rotation - deg_to_rad(90.0)
		proj.velocity = Vector2(cos(shoot_angle), sin(shoot_angle)) * power
	
	proj.rotation = proj.velocity.angle()
	
	if tower.level:
		tower.level.add_child(proj)
