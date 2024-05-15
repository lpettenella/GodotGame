class_name ChaseComponent
extends Area2D

@export var extend_ratio = 1.5

signal player_entered(body)
signal player_exited(body)

func _on_body_entered(body):
	if $CollisionShape2D.shape is RectangleShape2D:
		$CollisionShape2D.shape.size.x *= extend_ratio
	elif $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius *= extend_ratio
	player_entered.emit(body)

func _on_body_exited(body):
	if $CollisionShape2D.shape is RectangleShape2D:
		$CollisionShape2D.shape.size.x /= extend_ratio
	elif $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius /= extend_ratio
	player_exited.emit(body)
