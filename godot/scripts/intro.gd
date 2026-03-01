extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode = DisplayServer.window_get_mode()
		var is_windowed = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if is_windowed else DisplayServer.WINDOW_MODE_WINDOWED
		)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		#get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
		get_tree().change_scene_to_file("res://scenes/game.tscn")
