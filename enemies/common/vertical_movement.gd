extends MovementComponent
class_name VerticalMovement

@onready var character : CharacterBody2D = get_parent()

func move(_speed = SPEED, _direction = facing):
	character.velocity.y = _speed * _direction
