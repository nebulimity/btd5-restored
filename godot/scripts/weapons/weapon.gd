class_name Weapon
extends RefCounted

var weapon_range: float = 0.0
var reload_time: float = 0.0
var power: float = 0.0
var projectile: ProjectileDef = null
var proxied: bool = false

func execute(_tower: Tower, _source: Node2D, _target: Node2D, _offset: Vector2 = Vector2.ZERO) -> void:
	pass
