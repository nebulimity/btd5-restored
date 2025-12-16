class_name Projectile
extends Node2D

var def: ProjectileDef
var owner_tower: Tower
var velocity: Vector2 = Vector2.ZERO
var lifespan: float = 10.0
var max_lifespan: float = 10.0
var pierce: int = 1
var damage: int = 1
var hit_bloons: Array[int] = []
var target: Bloon = null
var sprite: AnimatedSprite2D
var damage_effect: DamageEffectDef
var level: Level

var radius: float = 0.0
var prev_pos: Vector2

func initialize(projectile_def: ProjectileDef) -> void:
	def = projectile_def
	pierce = def.pierce
	radius = def.radius
	damage_effect = def.damage_effect
	hit_bloons.clear()
	
	sprite = AnimatedSprite2D.new()
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 30.0)
	
	var base_path = projectile_def["display_path"].get_base_dir()
	var frame_index = 1
	
	while true:
		var frame_path = base_path + "/" + str(frame_index) + ".svg"
		if ResourceLoader.exists(frame_path):
			var texture = load(frame_path)
			sprite_frames.add_frame("default", texture)
			frame_index += 1
		else:
			break
	
	sprite.sprite_frames = sprite_frames
	sprite.play()
	add_child(sprite)
	
	prev_pos = global_position

func process(delta: float) -> void:
	lifespan -= delta
	
	prev_pos = global_position
	
	position += velocity * delta
	rotation = velocity.angle()
	
	if def.behavior and def.behavior.process_behavior:
		def.behavior.process_behavior.execute(self, delta)
	
	if lifespan <= 0:
		# TODO: check for LifespanOver
		destroy()
		return
	
	check_bloon_collisions(delta)

func check_bloon_collisions(_delta: float) -> void:
	if not owner_tower or not owner_tower.level or not owner_tower.level.collision_grid:
		return
	
	var move_dist = prev_pos.distance_to(global_position)
	var collision_radius = radius
	var max_bloon_radius = Bloon.max_radius

	var search_radius = move_dist / 2.0 + collision_radius + max_bloon_radius
	var search_center = (prev_pos + global_position) / 2.0
	
	var candidates = owner_tower.level.collision_grid.get_bloons_in_range(search_center, search_radius)
	
	for bloon in candidates:
		if not is_instance_valid(bloon) or bloon.bloon_type == -1: 
			continue
			
		if bloon.id in hit_bloons:
			continue
			
		var lineage_hit = false
		if "parentIDs" in bloon:
			for pid in bloon.parentIDs:
				if pid in hit_bloons:
					lineage_hit = true
					break
		if lineage_hit:
			continue
		
		var bloon_radius = bloon.radius
		var total_radius = collision_radius + bloon_radius
		
		var hit = false
		
		if global_position.distance_to(bloon.global_position) < total_radius:
			hit = true
		elif move_dist > 0:
			if line_intersects_circle(prev_pos, global_position, bloon.global_position, total_radius):
				hit = true
				
		if hit:
			bloon.handle_collision(self)
			if pierce <= 0:
				break

func line_intersects_circle(line_start: Vector2, line_end: Vector2, circle_center: Vector2, total_radius: float) -> bool:
	var d = line_end - line_start
	var f = line_start - circle_center
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - total_radius * total_radius
	
	var discriminant = b * b - 4 * a * c
	if discriminant < 0:
		return false
	
	discriminant = sqrt(discriminant)
	var t1 = (-b - discriminant) / (2 * a)
	var t2 = (-b + discriminant) / (2 * a)
	
	return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)

func destroy() -> void:
	if sprite.is_playing():
		if def.display == "MediumExplosion":
			var clip: TrailClip = TrailClip.new()
			clip.initialize(sprite.sprite_frames, sprite.frame)
			clip.position = position
			clip.rotation = rotation
			
			get_parent().add_child(clip)
		
	queue_free()
