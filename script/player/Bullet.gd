extends CharacterBody2D

const SPEED = 300
const UP = Vector2.UP

var motion = Vector2()
var direction = 1

func _physics_process(delta):
	motion.x += SPEED * direction
	$AnimatedSprite2D.play("main")
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity
	
func init(_direction):
	scale.x = _direction * -1
	direction = _direction

func _on_DamageArea_body_entered(body):
	if body.has_method("handle_hit"):
		body.handle_hit(direction)
#		$Camera2D/ScreenShake.start(Callable(0.1,12).bind(15),0)
