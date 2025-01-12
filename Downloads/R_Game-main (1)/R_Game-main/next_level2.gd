extends Area2D

@export var next_level: String = "res://level_3.tscn"  # Path to the next level
@onready var next_level_label = $NextLevelLabel  # Reference to a Label to display instructions (optional)

var player_in_area = false  # Tracks if the player is in the area

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
	next_level_label.visible = false  # Hide the instruction initially

func _process(delta: float) -> void:
	# If the player is in the area and presses "E", load the next level
	if player_in_area and Input.is_action_just_pressed("interact"):  # 'interact' is mapped to 'E'
		print("Player pressed E, loading next level.")
		get_tree().change_scene_to_file(next_level)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		print("Player entered the next level area.")
		player_in_area = true
		next_level_label.visible = true  # Show the instruction (optional)

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		print("Player exited the next level area.")
		player_in_area = false
		next_level_label.visible = false  # Hide the instruction (optional)
