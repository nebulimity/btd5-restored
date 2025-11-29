class_name ProjectileDef
extends RefCounted

var display_path: String = ""
var pierce: int = 1
var damage: int = 1
var speed: float = 100.0

func _init(path: String = "") -> void:
	display_path = path

func Display(path: String) -> ProjectileDef:
	display_path = path
	return self

func Pierce(value: int) -> ProjectileDef:
	pierce = value
	return self

func Damage(value: int) -> ProjectileDef:
	damage = value
	return self

func Speed(value: float) -> ProjectileDef:
	speed = value
	return self
