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
var damage_effect: DamageEffectDef
var effect_mask: int = 0
var level: Level

var radius: float = 0.0
var prev_pos: Vector2

var is_stationary: bool = false
var locked_target: Bloon = null

var sprite: FixedAnimatedSprite2D = null

func initialize(projectile_def: ProjectileDef) -> void:
	def = projectile_def
	pierce = def.pierce
	radius = def.radius
	damage_effect = def.damage_effect
	effect_mask = 0
	hit_bloons.clear()
	velocity = Vector2.ZERO
	target = null
	owner_tower = null
	is_stationary = false
	locked_target = null
	
	if sprite == null:
		sprite = get_node("Visuals/FixedAnimatedSprite2D")
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 30.0)
	
	for texture in AssetManager.grab(def["display"]):
		sprite_frames.add_frame("default", texture)
	
	sprite.sprite_frames = sprite_frames
	sprite.play()

	if def.effect_mask:
		for mask in def.effect_mask:
			effect_mask |= mask

func _enter_tree() -> void:
	prev_pos = global_position
	InterpolationManager.register(self)

func _exit_tree() -> void:
	InterpolationManager.unregister(self)

func process(delta: float) -> void:
	if def == null:
		return
	
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

func handle_collision() -> void:
	if def == null:
		return
	
	if not (def.get("ice_effect") and def.ice_effect.get("arctic_wind")):
		pierce -= 1
	
	if def.behavior and def.behavior.collision_behavior:
		def.behavior.collision_behavior.execute(self)
	
	if pierce <= 0:
		destroy()

func destroy() -> void:
	if def == null:
		return
	
	if sprite and sprite.is_playing():
		if def.display == "MediumExplosion" or def.display == "IceBurst":
			var clip: TrailClip = TrailClip.new()
			clip.initialize(sprite.sprite_frames, sprite.frame)
			clip.position = position
			clip.rotation = rotation
			get_parent().add_child(clip)
	
	if owner_tower and owner_tower.level:
		owner_tower.level.remove_projectile(self)
	
	def = null
	Pool.release(self)
