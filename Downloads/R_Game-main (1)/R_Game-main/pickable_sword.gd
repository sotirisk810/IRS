extends Area2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D
@onready var collision_shape = $InteractionArea/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_pick_up")


func _pick_up():
	sprite.visible = false if sprite.frame == 0 else true
	collision_shape.disabled = sprite.frame == 0
	var intM = get_node("/root/InteractionManager")
	intM.set_item_type("sword")
