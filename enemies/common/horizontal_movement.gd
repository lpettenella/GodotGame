extends MovementComponent
class_name HorizontalMovement

@onready var character : CharacterBody2D = get_parent()

func move(_direction = facing):
	character.velocity.x = SPEED * _direction
