class_name ProjectileDef
extends RefCounted

var display: String = ""
var pierce: int = 1
var radius: float = 0.0
var speed: float = 0.0
var damage_effect: DamageEffectDef = null
var behavior: BehaviorDef = null

func Display(path: String) -> ProjectileDef:
	display = path
	return self

func Pierce(value: int) -> ProjectileDef:
	pierce = value
	return self

func Radius(value: float) -> ProjectileDef:
	radius = value
	return self

func Speed(value: float) -> ProjectileDef:
	speed = value
	return self

func DamageEffect(effect: DamageEffectDef) -> ProjectileDef:
	damage_effect = effect
	return self

func Behavior(b: BehaviorDef) -> ProjectileDef:
	behavior = b
	return self
