class_name CollisionSpawnProjectile
extends BehaviorCollision

var new_projectile: ProjectileDef = null

func SetProjectile(value: ProjectileDef) -> CollisionSpawnProjectile:
	new_projectile = value
	return self

func execute(projectile: Projectile) -> void:
	projectile.pierce = 0
	
	var proj = Projectile.new()
	proj.initialize(new_projectile)
	proj.owner_tower = projectile.owner_tower
	proj.position = projectile.global_position
	proj.lifespan = 0.1
	proj.rotation = projectile.rotation
	
	if new_projectile.display == "MediumExplosion":
		SoundManager.play("explosion_medium")
	
	if proj.owner_tower.level:
		proj.owner_tower.level.add_projectile(proj)
