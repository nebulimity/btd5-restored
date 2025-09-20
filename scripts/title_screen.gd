extends Node2D

func _process(delta: float) -> void:
	$Icon.scale[0] += 0.1 * delta
