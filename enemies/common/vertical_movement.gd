extends MovementComponent
class_name VerticalMovement

@onready var character : CharacterBody2D = get_parent()

func move(_direction = facing):
	character.velocity.y = SPEED * facing
