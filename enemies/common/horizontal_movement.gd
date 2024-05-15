extends MovementComponent
class_name HorizontalMovement

@onready var character : CharacterBody2D = get_parent()

func move(_speed = SPEED, _direction = facing):
	character.velocity.x = _speed * _direction
