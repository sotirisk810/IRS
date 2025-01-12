extends Control

func resume():
	get_tree().paused = false

func pause():
	get_tree().paused = true

func ingame_menu():
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
		show()
	elif Input.is_action_just_pressed("escape") and get_tree().paused == true:
		resume()
		hide()


func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	ingame_menu()
