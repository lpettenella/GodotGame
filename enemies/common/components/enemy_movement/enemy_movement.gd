class_name EnemyMovement
extends MovementComponent

@export var check_terrain : RayCast2D
@export var can_float = false

@onready var enemy = get_parent()
@onready var animated_sprite : AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta):
	vertical_movement()
	enemy.move_and_slide()
	
func vertical_movement():
	if can_float:
		return
	if enemy.GRAVITY >= enemy.FALL_LIMIT:
		enemy.velocity.y = enemy.FALL_LIMIT
	else:
		enemy.velocity.y += enemy.GRAVITY

func move(_speed = SPEED):
	_speed = _speed if can_move() else 0

	enemy.velocity.x = _speed * facing
	if can_float:
		enemy.velocity.y = 0
		
	animated_sprite.play("run")
	
func stop():
	enemy.velocity.x = 0
	if can_float:
		enemy.velocity.y = 0
	animated_sprite.play("idle")
	
func chase(_direction, _target, _gap, _speed = SPEED):
	_speed = _speed if can_move() else 0
	
	if abs(_target.global_position.x - enemy.global_position.x) > _gap:
		enemy.velocity.x = _direction.normalized().x * _speed
		if can_float:
			enemy.velocity.y = _direction.normalized().y * _speed
		if can_move(): 
			animated_sprite.play("run")
		else: 
			animated_sprite.play("idle")
	else:
		enemy.velocity = Vector2()
		animated_sprite.play("idle")

func change_direction():
	facing *= -1
	enemy.scale.x *= -1
	
func can_move():
	if not check_terrain: 
		return true
	else:
		return check_terrain.is_colliding()
