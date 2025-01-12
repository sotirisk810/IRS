extends CharacterBody2D

@export var speed = 150
@export var nav_agent: NavigationAgent2D
@onready var path_timer: Timer = $Navigation/Timer  # Timer to recalculate paths
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_range: CollisionShape2D = $AnimatedSprite2D/SwordHit/CollisionShape2D
@onready var attack_timer: Timer = $AnimatedSprite2D/SwordHit/Timer

var target_node: Node2D = null
var home_pos: Vector2 = Vector2.ZERO
var is_attacking: bool = false  # Flag for attacking
var health: int = 100

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
		update_animation(axis)
	else:
		velocity = Vector2.ZERO
	
func update_animation(direction: Vector2) -> void:
	# Update walking animations based on direction
	var new_animation = "walk"
	if abs(direction.x) > abs(direction.y):  # Horizontal movement
		animated_sprite.flip_h = direction.x < 0
		update_attack_range("left" if direction.x < 0 else "right")
	else:  # Vertical movement
		new_animation = "up" if direction.y < 0 else "down"
		update_attack_range("up" if direction.y < 0 else "down")

	if not is_attacking and animated_sprite.animation != new_animation:
		animated_sprite.animation = new_animation
		animated_sprite.play()

func update_attack_range(direction: String) -> void:
	# Move attack range position based on facing direction
	match direction:
		"right": attack_range.position = Vector2(20, 0)
		"left": attack_range.position = Vector2(-20, 0)
		"up": attack_range.position = Vector2(0, -20)
		"down": attack_range.position = Vector2(0, 20)

func take_damage(damage: int) -> void:
	health -= damage
	print("Enemy took damage, health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Enemy died")
	queue_free()
	
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


func _on_sword_hit_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent == self:
		print("Self-detection skipped.")
		return  # Skip if the area belongs to the enemy itself

	print("Parent node:", parent)

	if parent.has_method("take_damage"):
		print("Player hit!")
		is_attacking = true
		animation_player.play("hit")
		parent.take_damage(1)  # Apply damage to the player
	else:
		print("Error: Could not find 'take_damage' in the detected parent.")
	#if area.is_in_group("player") and not is_attacking:
		#print("Player hit!")
		#is_attacking = true
		#animation_player.play("hit")
		#area.get_parent().take_damage(20)  # Call player's take_damage function

func _on_attack_finished() -> void:
	print("telos to attack")
	is_attacking = false
