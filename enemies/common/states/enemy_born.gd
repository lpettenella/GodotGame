class_name EnemyBorn
extends EnemyState

func enter(_msg := {}):
	animated_sprite.play("born")
	
func physics_update(_delta: float):
	if not animated_sprite.is_playing():
		if enemy.target:
			Transitioned.emit(self, "Chase")
		else:
			Transitioned.emit(self, "Wander")
		return
	
func exit():
	pass
