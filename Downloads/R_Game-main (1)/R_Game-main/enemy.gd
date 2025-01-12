extends CharacterBody2D

@export var speed = 300
@export var nav_agent: NavigationAgent2D
@onready var path_timer: Timer = $Navigation/Timer  # Timer to recalculate paths

var target_node: Node2D = null
var home_pos: Vector2 = Vector2.ZERO

func _ready():
	home_pos = self.global_position

	if nav_agent == null:
		print("Error: NavigationAgent2D not found!")
		return

	nav_agent.path_desired_distance = 1.0
	nav_agent.target_desired_distance = 1.0

	# Connect signals for Aggro and DeAggro areas
	$Aggro.connect("area_entered", Callable(self, "_on_aggro_area_entered"))
	$DeAggro.connect("area_exited", Callable(self, "_on_de_aggro_area_exited"))

	# Connect timer
	path_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	path_timer.wait_time = 0.2  # Update every 0.2 seconds
	path_timer.one_shot = false

func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		return

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	if axis.length() > 0:
		velocity = axis * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func recalc_path():
	if target_node:
		nav_agent.target_position = target_node.global_position
	else:
		nav_agent.target_position = home_pos

func _on_timer_timeout():
	recalc_path()

func _on_aggro_area_entered(area: Area2D) -> void:
	print("Player entered aggro range")
	target_node = area.get_parent()
	path_timer.start()  # Start recalculating paths periodically
	recalc_path()

func _on_de_aggro_area_exited(area: Area2D) -> void:
	print("Player exited aggro range")
	if area.get_parent() == target_node:
		target_node = null
		path_timer.stop()  # Stop recalculating paths
		recalc_path()
