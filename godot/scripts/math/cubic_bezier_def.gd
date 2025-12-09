class_name CubicBezierDef
extends Resource

var a: Vector2 = Vector2.ZERO
var b: Vector2 = Vector2.ZERO
var c: Vector2 = Vector2.ZERO
var d: Vector2 = Vector2.ZERO

func A(val: Vector2) -> CubicBezierDef:
	a = val
	return self

func B(val: Vector2) -> CubicBezierDef:
	b = val
	return self

func C(val: Vector2) -> CubicBezierDef:
	c = val
	return self

func D(val: Vector2) -> CubicBezierDef:
	d = val
	return self
