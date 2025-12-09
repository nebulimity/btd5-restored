class_name MoveLinear
extends BehaviorProcess

func execute(projectile: Projectile, delta: float) -> void:
	projectile.position += projectile.velocity * delta
	projectile.rotation = projectile.velocity.angle()
