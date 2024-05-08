class_name EnemyWander
extends EnemyState

@export var MOVING_TIME = 2.0
@export var PAUSE_TIME = 1.0
@export var WANDER_SPEED = 10

var moving_timer = 0.0
var pause_timer = 0.0
var moving = false

func enter(_msg := {}):
	moving_timer = 0.0
	pause_timer = 0.0
	
func physics_update(_delta: float):
	if moving:
		moving_timer += _delta
		movement.move(WANDER_SPEED)
	else:
		pause_timer += _delta
		movement.stop()
		
	if moving_timer > MOVING_TIME:
		moving = false
		moving_timer = 0.0
		
	if pause_timer > PAUSE_TIME:
		if randi() % 2 == 0:
			movement.change_direction()
		moving = true
		pause_timer = 0.0
	
func exit():
	pass
