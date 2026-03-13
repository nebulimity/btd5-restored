class_name GlueEffectDef
extends RefCounted

var lifespan: float = 0.0
var speed_scale: float = 0.0
var soak: bool = false

func Lifespan(value: float) -> GlueEffectDef:
	lifespan = value
	return self

func SpeedScale(value: float) -> GlueEffectDef:
	speed_scale = value
	return self

func Soak(value: bool) -> GlueEffectDef:
	soak = value
	return self
