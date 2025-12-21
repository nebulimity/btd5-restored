class_name IceEffectDef
extends RefCounted

var lifespan: float = 0.0
var cant_break_types: Array = []
var can_break_ice: bool = true
var show_pop: bool = true

func Lifespan(value: float) -> IceEffectDef:
	lifespan = value
	return self
