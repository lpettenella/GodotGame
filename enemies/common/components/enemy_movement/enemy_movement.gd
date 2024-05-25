class_name EnemyMovement
extends MovementComponent

@export var check_terrain : RayCast2D
@export var can_float = false
@export var horizontal_movement : MovementComponent
@export var vertical_movement : MovementComponent

@onready var enemy = get_parent()
@onready var animated_sprite : AnimatedSprite2D = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta):
	handle_gravity()
	enemy.move_and_slide()
	
func handle_gravity():
	if can_float:
		return
	if enemy.GRAVITY >= enemy.FALL_LIMIT:
		enemy.velocity.y = enemy.FALL_LIMIT
	else:
		enemy.velocity.y += enemy.GRAVITY

func move(_speed = SPEED, _direction = facing):
	if not can_move():
		return
	if horizontal_movement:
		horizontal_movement.move(_speed, _direction)
	if vertical_movement:
		vertical_movement.move(_speed, _direction)

	animated_sprite.play("run")
	
func stop():
	enemy.velocity.x = 0
	if can_float:
		enemy.velocity.y = 0
	animated_sprite.play("idle")
	
func chase(_direction, _target, _gap, _speed = SPEED):
	_speed = _speed if can_move() else 0

	if _target.global_position.distance_to(enemy.global_position) > _gap:
		if horizontal_movement:
			horizontal_movement.move(_speed, _direction.normalized().x)
		if vertical_movement:
			vertical_movement.move(_speed, _direction.normalized().y)

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
