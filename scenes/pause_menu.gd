extends ColorRect


func _input(event):
	if event.is_action_pressed("pause"):
		if GS.get_game_time_left() <= 0.0:
			return
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
