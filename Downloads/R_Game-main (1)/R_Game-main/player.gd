extends CharacterBody2D

@export var MAX_SPEED = 350
@export var ACCELERATION = 1500
@export var FRICTION = 1200
@export var speed: float = 100.0
@export var max_health: int = 100
@export var attacking: bool = false

@onready var axis = Vector2.ZERO
@onready var screen_size : Vector2 = Vector2.ZERO
@onready var intM = get_node("/root/InteractionManager")
@onready var main_node = get_node("/root/Main")
@onready var hitbox_area = $HitBox
@onready var animation_player = $AnimationPlayer
@onready var hp_bar = $HP
@onready var animated_sprite = $AnimatedSprite2D

signal hit

var health: int
var type: String

func _ready() -> void:
	screen_size = get_viewport_rect().size
	health = max_health
	hp_bar.value = health

	hitbox_area.connect("area_entered", Callable(self, "_on_hit_box_area_entered"))
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if attacking:
		return  # Skip movement while attacking

	update_item_type()
	handle_input(delta)
	move_and_slide()

func handle_input(delta: float) -> void:
	var input_axis = get_input_axis()

	if input_axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
	else:
		apply_movement(input_axis * ACCELERATION * delta)

	if velocity.length() > 0:
		animated_sprite.play()
		update_animation(velocity)
	else:
		animated_sprite.stop()

	if Input.is_action_just_pressed("basic_attack"):
		if type == "sword":
			perform_attack()

func get_input_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()

func apply_friction(amount: float):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel: Vector2):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)

func perform_attack() -> void:
	attacking = true
	animation_player.play("basic_attack")

func update_animation(velocity: Vector2) -> void:
	if velocity.x != 0:
		if type == "sword":
			animation_player.play("walk_sword")
		else:
			animated_sprite.animation = "walk"
		animated_sprite.flip_h = velocity.x < 0
		hitbox_area.scale.x = 1 if velocity.x > 0 else -1
	elif velocity.y < 0:
		if type == "sword":
			animation_player.play("up_sword")
		else:
			animated_sprite.animation = "up"
	elif velocity.y > 0:
		if type == "sword":
			animation_player.play("down_sword")
		else:
			animated_sprite.animation = "down"

func update_item_type() -> void:
	if intM and intM.has_method("set_item_type"):
		type = intM.item_type
	else:
		print("Error: InteractionManager not found or invalid.")

func take_damage(damage: int) -> void:
	health -= damage
	hp_bar.value = health
	if health <= 0:
		die()

func die() -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		print("Attacking enemy.")
		main_node.remove_enemy(area)
		area.queue_free()


func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "basic_attack":
		attacking = false
