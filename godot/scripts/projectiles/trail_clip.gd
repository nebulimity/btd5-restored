class_name TrailClip
extends Node2D

var sprite: AnimatedSprite2D = null

func initialize(sprite_frames, frame_index) -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = sprite_frames
	sprite.sprite_frames.set_animation_loop(sprite.animation, false)
	sprite.frame = frame_index
	
	sprite.play()
	sprite.animation_finished.connect(_on_animation_finished)
	
	add_child(sprite)

func _on_animation_finished() -> void:
	queue_free()
