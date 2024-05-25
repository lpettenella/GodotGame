class_name EnemyStun
extends EnemyState

@export var stun_time = 2.0
var stun_timer = 0.0

func enter(_msg := {}):
	enemy.modulate = Color(Color.BLUE)
	animated_sprite.play("idle")
	
func physics_update(_delta: float):
	stun_timer += _delta
	
	if stun_timer >= stun_time:
		Transitioned.emit(self, "Wander")	
	
	movement.stop()
	
func exit():
	enemy.modulate = Color(255, 255, 255)
	stun_timer = 0.0
