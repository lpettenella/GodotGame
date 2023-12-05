extends CharacterBody2D

const GRAVITY = 80
const UP = Vector2.UP

func _physics_process(delta):
	velocity.y += GRAVITY
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	
func get_eaten():
	queue_free()
