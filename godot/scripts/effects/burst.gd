class_name Burst
extends Node2D

const FRAME_DURATION = 1.0 / 30.0

var _elapsed: float = 0.0

func initialize() -> void:
	z_index = 5
	rotation = randf() * TAU
	_elapsed = 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= FRAME_DURATION:
		Pool.release(self)
