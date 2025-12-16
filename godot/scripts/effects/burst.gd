class_name Burst
extends Sprite2D

var timer: Timer

func initialize() -> void:
	z_index = 5
	texture = AssetManager.grab("Burst")
	rotation = randf() * TAU
	
	timer = Timer.new()
	timer.wait_time = 0.033 #* Engine.time_scale
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _ready() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
