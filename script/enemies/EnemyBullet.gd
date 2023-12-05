extends CharacterBody2D

const SPEED = 300

var direction: Vector2

func _physics_process(delta):
	$AnimatedSprite2D.play("main")
	var collision = move_and_collide(velocity.normalized() * delta * SPEED)
	
func init(_direction_to):
	direction = _direction_to
	look_at(direction)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		body.get_damage(-1)
	queue_free()
		
