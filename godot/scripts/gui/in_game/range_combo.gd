class_name RangeCombo
extends Node2D

var range_shade: Node2D
var range_outline: Node2D

func _init() -> void:
	range_shade = RangeShade.new()
	range_outline = RangeOutline.new()
	add_child(range_shade)
	add_child(range_outline)

func redraw(target_range, is_valid) -> void:
	range_shade.redraw(target_range, is_valid)
	range_outline.redraw(target_range, is_valid)
