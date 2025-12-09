class_name CubicBezier
extends RefCounted

var a: Vector2
var b: Vector2
var c: Vector2
var d: Vector2

func initialize(def: CubicBezierDef) -> void:
	a = def.a
	b = def.b
	c = def.c
	d = def.d

func get_point(t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t

	return (uuu * a) + (3 * uu * t * b) + (3 * u * tt * c) + (ttt * d)
