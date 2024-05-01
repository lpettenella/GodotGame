class_name EnemyIdle
extends EnemyState

func enter(_msg := {}):
	animated_sprite.play("idle")
	pass
	
func physics_update(_delta: float):
	pass
	
func exit():
	pass
