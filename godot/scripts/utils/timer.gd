class_name CustomTimer
extends RefCounted

signal complete
signal destroyed

var delay: float = 0.0
var current: float = 0.0
var running: bool = false
var repeat: int = 1
var initialRepeat: int = 1
var extra: Variant = null

func _init(timer_delay: float = 0.0, timer_repeat: int = 1) -> void:
	delay = timer_delay
	repeat = timer_repeat
	initialRepeat = timer_repeat
	start()

func initialize(timer_delay: float, timer_repeat: int = 1) -> void:
	delay = timer_delay
	repeat = timer_repeat
	initialRepeat = timer_repeat
	current = 0.0
	running = false
	start()

func destroy() -> void:
	emit_signal("destroyed")

func start() -> void:
	if not running:
		running = true

func stop() -> void:
	if running:
		running = false

func reset() -> void:
	stop()
	current = 0.0
	repeat = initialRepeat
	start()

func process(delta: float) -> void:
	if not running:
		return

	if delay <= 0.011:
		delay = 0.011
	
	current += delta
	
	while current >= delay:
		current -= delay
		repeat -= 1
		
		if repeat <= 0:
			stop()
			destroy()
		
		emit_signal("complete")
		
		if repeat <= 0:
			break
