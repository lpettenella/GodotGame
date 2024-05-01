class_name ChaseComponent
extends Area2D

@export var extend_ratio = 1.5

signal player_entered(body)
signal player_exited(body)

func _on_body_entered(body):
	if body.name == "Player":
		$CollisionShape2D.shape.size.x *= 1.5
		player_entered.emit(body)

func _on_body_exited(body):
	if body.name == "Player":
		$CollisionShape2D.shape.size.x /= 1.5
		player_exited.emit(body)
