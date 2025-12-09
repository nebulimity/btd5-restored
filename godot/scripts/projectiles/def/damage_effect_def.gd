class_name DamageEffectDef
extends RefCounted

var damage: int = 1
var cant_break_types: Array = []
var can_break_ice: bool = true

func Damage(val: int) -> DamageEffectDef:
	damage = val
	return self

func CantBreak(types: Array) -> DamageEffectDef:
	cant_break_types = types
	return self

func CanBreakIce(can: bool) -> DamageEffectDef:
	can_break_ice = can
	return self
