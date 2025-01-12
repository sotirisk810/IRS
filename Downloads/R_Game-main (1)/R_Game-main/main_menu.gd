class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var start_game = preload("res://main.tscn") as PackedScene

func ready():
	start_button.button_down.connect(_on_start_button_pressed)
	exit_button.button_down.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_game)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
