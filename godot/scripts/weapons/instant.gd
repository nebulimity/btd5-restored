class_name Instant
extends Weapon

var rotate: bool = true
var offset_sequence: Array[Vector2] = []
var offset_index: int = 0

func SetRange(value: float) -> Instant:
	weapon_range = value
	return self

func SetReloadTime(value: float) -> Instant:
	reload_time = value
	return self

func SetPower(value: float) -> Instant:
	power = value
	return self

func SetProjectile(proj: ProjectileDef) -> Instant:
	projectile = proj
	return self

func SetRotate(value: bool) -> Instant:
	rotate = value
	return self

func execute(tower: Tower, _source: Node2D, _target_arg: Node2D, _weapon_offset: Vector2 = Vector2.ZERO) -> void:
	if not projectile:
		return
	
	var candidate: Bloon = null
	var final_target: Bloon = null
	var i: int = int(tower.targets_by_priority.size() - 1)
	
	while i >= 0:
		candidate = tower.targets_by_priority[i]
		if candidate.bloon_type != -1:
			final_target = candidate
			break
		i -= 1
	
	if final_target == null:
		tower.sprite.frame = 0
		tower.sprite.stop()
		tower.in_throw_animation = false
		return
	
	var proj = Projectile.new()
	proj.initialize(projectile)
	proj.owner_tower = tower
	
	final_target.handle_collision(proj)
	proj.queue_free()
	
	var direction = final_target.global_position - tower.global_position
	tower.rotation = direction.angle() + deg_to_rad(90.0)
