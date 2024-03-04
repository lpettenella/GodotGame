extends CharacterBody2D

const SPEED = 300

var direction = 1

func _physics_process(delta):
	$AnimatedSprite2D.play("main")
	var collision = move_and_collide(velocity.normalized() * delta * SPEED)
	
	direction = 1 if velocity.x > 0 else -1
	
	
#func init(_direction_to):
	#direction = _direction_to
	#look_at(direction)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		body.get_damage(direction)
	queue_free()
		
