class_name ProjectileDef
extends RefCounted

var display_path: String = ""
var pierce: int = 1
var radius: float = 0.0
var speed: float = 0.0
var damage_effect: DamageEffectDef = null
var behavior: BehaviorDef = null

func _init(path: String = "") -> void:
	display_path = path
	damage_effect = DamageEffectDef.new().Damage(1) 
	behavior = BehaviorDef.new().Process(MoveLinear.new())

func Display(path: String) -> ProjectileDef:
	display_path = path
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
