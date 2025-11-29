class_name Weapon
extends RefCounted

var weapon_range: float = 0.0
var reload_time: float = 0.0
var power: float = 0.0
var projectile: ProjectileDef = null
var proxied: bool = false
var reload_timer: float = 0.0

func execute(_tower: Tower, _source: Node2D, _target: Node2D, _offset: Vector2 = Vector2.ZERO) -> void:
	pass

func can_fire() -> bool:
	return reload_timer <= 0.0

func update(delta: float) -> void:
	if reload_timer > 0:
		reload_timer -= delta
