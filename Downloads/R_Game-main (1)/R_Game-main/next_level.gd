extends Area2D

@export var next_level: String = "res://level_2.tscn"  # Path to the next level
@onready var next_level_label = $NextLevelLabel  # Optional label for instructions

var player_in_area = false  # Tracks if the player is in the area

func _ready() -> void:
	# Connect signals
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	if next_level_label:
		next_level_label.visible = false  # Hide the label initially
	print("Next_level script ready!")

func _process(delta: float) -> void:
	# Check for player interaction
	if player_in_area and Input.is_action_just_pressed("interact"):  # 'interact' is mapped to 'E'
		print("Player pressed E, loading next level.")
		get_tree().change_scene_to_file(next_level)

func _on_area_entered(area: Area2D) -> void:
	print("Something entered the area:", area)
	if area.get_parent().is_in_group("player"):
		print("Player entered the next level area.")
		player_in_area = true
		if next_level_label:
			next_level_label.visible = true  # Show the label

func _on_area_exited(area: Area2D) -> void:
	print("Something exited the area:", area)
	if area.get_parent().is_in_group("player"):
		print("Player exited the next level area.")
		player_in_area = false
		if next_level_label:
			next_level_label.visible = false  # Hide the label
