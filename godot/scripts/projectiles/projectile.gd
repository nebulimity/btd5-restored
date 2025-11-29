class_name Projectile
extends Node2D

var def: ProjectileDef
var owner_tower: Tower
var velocity: Vector2 = Vector2.ZERO
var lifespan: float = 10.0
var pierce: int = 1
var damage: int = 1
var hit_bloons: Array[int] = []
var target: Bloon = null
var sprite: Sprite2D

#func _ready() -> void:
	#sprite = Sprite2D.new()
	#add_child(sprite)

func initialize(projectile_def: ProjectileDef) -> void:
	def = projectile_def
	pierce = projectile_def.pierce
	damage = projectile_def.damage
	hit_bloons.clear()
	
	sprite = Sprite2D.new()
	add_child(sprite)
	
	sprite.texture = load(projectile_def.display_path)

func _process(delta: float) -> void:
	position += velocity * delta
	lifespan -= delta
	
	rotation = velocity.angle()
	
	if lifespan <= 0:
		destroy()
		return
	
	check_bloon_collisions(delta)

func check_bloon_collisions(delta: float) -> void:
	if not owner_tower or not owner_tower.level:
		return
	
	var bloons = owner_tower.level.get_bloons()
	var collision_radius = 10.0
	var velocity_magnitude = velocity.length()
	
	for bloon in bloons:
		if bloon.id in hit_bloons:
			continue
		
		var dist = position.distance_to(bloon.position)
		var bloon_radius = 8.0
		
		if dist < (collision_radius + bloon_radius + velocity_magnitude):
			if dist < (collision_radius + bloon_radius):
				handle_collision(bloon)
			else:
				var prev_pos = position - velocity * delta
				if line_intersects_circle(prev_pos, position, bloon.position, bloon_radius):
					handle_collision(bloon)
		
		if pierce <= 0:
			break

func line_intersects_circle(line_start: Vector2, line_end: Vector2, circle_center: Vector2, circle_radius: float) -> bool:
	var d = line_end - line_start
	var f = line_start - circle_center
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - circle_radius * circle_radius
	
	var discriminant = b * b - 4 * a * c
	if discriminant < 0:
		return false
	
	discriminant = sqrt(discriminant)
	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)
	
	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)

func handle_collision(bloon: Bloon) -> void:
	hit_bloons.append(bloon.id)
	bloon.damage(damage)
	
	pierce -= 1
	if pierce <= 0:
		destroy()

func destroy() -> void:
	queue_free()
