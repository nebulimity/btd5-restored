extends Node

var time_scale: float = 1.0

var min_fps: float = 30.0
var max_frame_time: float = 1.0 / min_fps

var _last_time_usec: int = 0

func _ready():
	process_priority = -100 
	_last_time_usec = Time.get_ticks_usec()

func _process(_delta):
	var current_time_usec = Time.get_ticks_usec()
	var real_frame_time = (current_time_usec - _last_time_usec) / 1000000.0
	_last_time_usec = current_time_usec
	
	if real_frame_time <= 0.0:
		return
		
	if real_frame_time > max_frame_time:
		var lag_compensation = max_frame_time / real_frame_time
		
		Engine.time_scale = time_scale * lag_compensation
	else:
		Engine.time_scale = time_scale
