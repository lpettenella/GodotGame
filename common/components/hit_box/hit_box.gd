extends Area2D

@export var movement_component : MovementComponent

func _on_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(movement_component.facing)
