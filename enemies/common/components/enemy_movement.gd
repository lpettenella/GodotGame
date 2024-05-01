class_name EnemyMovement
extends MovementComponent

@onready var enemy = get_parent()
@onready var animated_sprite : AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")

func move(_speed = SPEED):
	enemy.velocity.x = _speed * facing
	animated_sprite.play("run")
	
func stop():
	enemy.velocity.x = 0
	animated_sprite.play("idle")
	
func chase(_direction, _target, _gap, _speed = SPEED):
	if abs(_target.global_position.x - enemy.global_position.x) > _gap:
		enemy.velocity.x = _direction.normalized().x * _speed
		animated_sprite.play("run")
	else:
		enemy.velocity = Vector2()
		animated_sprite.play("idle")

func change_direction():
	facing *= -1
	enemy.scale.x *= -1
	
