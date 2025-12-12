class_name RotateToTarget
extends RefCounted

func process(tower: Tower, _delta: float) -> void:
	if not tower.in_throw_animation or not tower.current_target or not is_instance_valid(tower.current_target):
		return
	
	var vec = tower.current_target.global_position - tower.global_position
	var target_angle = vec.angle()
	
	tower.rotation = target_angle + deg_to_rad(90.0)
