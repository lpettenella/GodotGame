extends PlayerState
class_name PlayerFreeze

func enter(_msg := {}):
	animated_sprite.play("idle")
	
func physics_update(_delta: float):
	if !player.freeze_conditions():
		Transitioned.emit(self, "idle")
		
	player.velocity.x = 0
	player.move_and_slide()
	
