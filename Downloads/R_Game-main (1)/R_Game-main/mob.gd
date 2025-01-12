extends RigidBody2D

@export var speed = 1.0

# called when the mob enters the scene tree for the first time
func _ready() -> void:
	randomize()
	start_movement()

func start_movement() -> void:
	var velocity = Vector2.ZERO
	var random_direction = randi() % 4  # 0 = right, 1 = left, 2 = up, 3 = down
	
	match random_direction:
		0:
			velocity = Vector2(speed, 0)
			$AnimatedSprite2D.animation="walk"
		1:
			velocity = Vector2(-speed, 0)
			get_node("AnimatedSprite2D").animation = "walk"
			$AnimatedSprite2D.flip_v=false
			$AnimatedSprite2D.flip_h=velocity.x<0
		2:
			velocity = Vector2(0, -speed)
			$AnimatedSprite2D.animation="up"
		3:
			velocity = Vector2(0, speed)
			$AnimatedSprite2D.animation="down"
	
	# Apply linear velocity to move the mob in the chosen direction
	#linear_velocity = velocity
	
	#play coresponding animation
	get_node("AnimatedSprite2D").play()
