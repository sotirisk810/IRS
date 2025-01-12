class_name HitBox
extends Area2D

func _ready() -> void:
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("HurtBox"):
		return
	print("Hit detected on:", area.name)
