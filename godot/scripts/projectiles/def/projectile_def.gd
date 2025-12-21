class_name ProjectileDef
extends RefCounted

var display: String = ""
var pierce: int = 1
var radius: float = 0.0
var effect_mask: Array[int] = []
var speed: float = 0.0
var damage_effect: DamageEffectDef = null
var ice_effect: IceEffectDef = null
var behavior: ProjectileBehaviorDef = null

func _init() -> void:
	effect_mask.resize(Bloon.BloonImmunity.size())
	effect_mask.fill(Bloon.BloonImmunity.IMMUNITY_NO_DETECTION)

func Display(path: String) -> ProjectileDef:
	display = path
	return self

func Pierce(value: int) -> ProjectileDef:
	pierce = value
	return self

func Radius(value: float) -> ProjectileDef:
	radius = value
	return self

func EffectMask(value: Array[int]) -> ProjectileDef:
	effect_mask = value
	return self

func Speed(value: float) -> ProjectileDef:
	speed = value
	return self

func DamageEffect(effect: DamageEffectDef) -> ProjectileDef:
	damage_effect = effect
	return self

func IceEffect(effect: IceEffectDef) -> ProjectileDef:
	ice_effect = effect
	return self

func Behavior(b: ProjectileBehaviorDef) -> ProjectileDef:
	behavior = b
	return self
