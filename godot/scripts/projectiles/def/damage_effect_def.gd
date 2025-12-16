class_name DamageEffectDef
extends RefCounted

var damage: int = 1
var cant_break_types: Array = []
var can_break_ice: bool = true
var show_pop: bool = true

func Damage(value: int) -> DamageEffectDef:
	damage = value
	return self

func CantBreak(value: Array) -> DamageEffectDef:
	cant_break_types = value
	return self

func CanBreakIce(value: bool) -> DamageEffectDef:
	can_break_ice = value
	return self

func ShowPop(value: bool) -> DamageEffectDef:
	show_pop = value
	return self
