extends Node

var max_dt: float = 1.0 / 30.0 
var time_scale: float = 1.0 

var delta: float:
	get:
		var real_delta = get_process_delta_time()
		var clamped_delta = min(real_delta, max_dt)
		
		return clamped_delta * time_scale
