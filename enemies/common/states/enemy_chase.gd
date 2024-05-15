class_name EnemyChase
extends EnemyState

@export var GAP = 25

var player : CharacterBody2D
var from_hit = false

func enter(_msg := {}):
	animated_sprite.play("run")
	if _msg.has("from_hit"):
		from_hit = true
	player = enemy.target
	
func physics_update(_delta: float):
	if from_hit and not enemy.is_on_floor() and not movement.can_float:
		return
		
	var direction = player.global_position - enemy.global_position
	
	if player.global_position.x < enemy.global_position.x: 
		if movement.facing != -1:
			movement.change_direction()
	else: 
		if movement.facing != 1:
			movement.change_direction()
	
	movement.chase(direction, player, GAP)
	
func exit():
	pass
