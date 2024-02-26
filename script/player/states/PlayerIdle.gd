extends PlayerState
class_name PlayerIdle

func enter(_msg := {}):
	animated_sprite.play("idle")
	
func physics_update(_delta: float):
	if not player.is_on_floor():
		Transitioned.emit(self, "air")
		if player.is_on_wall_check():
			Transitioned.emit(self, "wall")
		
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.3)
	player.move_and_slide()
	
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		Transitioned.emit(self, "run")
	elif Input.is_action_pressed("jump"):
		Transitioned.emit(self, "air", {do_jump = true})
	elif Input.is_action_just_pressed("attack"):
		player.combo_count = (player.combo_count + 1) % 3
		Transitioned.emit(self, player.melee_map[player.combo_count])

