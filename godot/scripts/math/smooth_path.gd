class_name SmoothPath
extends RefCounted

var curves: Array[CubicBezier] = []
var curve_count: int = 0

func initialize(p_curves: Array[CubicBezier]) -> void:
	curves = p_curves
	curve_count = curves.size()

func get_transformed_value(t: float, rotation: float, offset_x: float, offset_y: float) -> Vector2:
	if curve_count == 0:
		return Vector2(offset_x, offset_y)
		
	var segment_index = int(t * curve_count)
	
	if segment_index >= curve_count:
		segment_index = curve_count - 1
		
	var segment_t = (t * curve_count) - segment_index
	var raw_point = curves[segment_index].get_point(segment_t)
	
	var final_point = raw_point.rotated(rotation)
	final_point.x += offset_x
	final_point.y += offset_y
	
	return final_point
