extends PlayerState
class_name PlayerFreeze

func enter(_msg := {}):
	animated_sprite.play("idle")
	player.velocity.x = 0
	
func physics_update(_delta: float):
	if !player.freeze_conditions():
		Transitioned.emit(self, "idle")
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
