extends AnimatedSprite2D
class_name FixedAnimatedSprite2D

var _anim_timer: float = 0.0
var _was_playing: bool = false 

func _ready() -> void:
	speed_scale = 0.0 
	add_to_group("fixed_animators")

func advance_time(fixed_step: float) -> void:
	var currently_playing = is_playing()
	
	if currently_playing and not _was_playing:
		_anim_timer = 0.0
		frame = 0
		
	_was_playing = currently_playing
	
	if not currently_playing or not sprite_frames or not animation:
		return
		
	var fps = sprite_frames.get_animation_speed(animation)
	if fps <= 0.0: return
	
	var time_per_frame = 1.0 / fps
	_anim_timer += fixed_step
	
	while _anim_timer >= time_per_frame:
		if not is_playing():
			break
			
		var total_frames = sprite_frames.get_frame_count(animation)
		if total_frames > 0:
			var next_frame = frame + 1
			var does_loop = sprite_frames.get_animation_loop(animation)
			
			if next_frame >= total_frames:
				if does_loop:
					frame = 0
				else:
					frame = total_frames - 1
					pause() 
					_was_playing = false 
					animation_finished.emit() 
					
					break
			else:
				frame = next_frame
				
		_anim_timer -= time_per_frame
