extends PlayerState
class_name PlayerRun

func enter(_msg := {}):
	player.jump_timer = 0.0
	player.jumped = false
	animated_sprite.play("run")
	
func physics_update(_delta: float):
	if player.just_hitted:
		Transitioned.emit(self, "hit")
		return
		
	if player.dash_conditions():
		Transitioned.emit(self, "dash")
		return
		
	if player.eat_conditions():
		Transitioned.emit(self, "eat")
		return
		
	if not player.is_on_floor():
		Transitioned.emit(self, "air")
		if player.is_on_wall_check():
			Transitioned.emit(self, "wall")
	elif Input.is_action_just_pressed("attack"):
		player.combo_count = (player.combo_count + 1) % 3
		Transitioned.emit(self, player.melee_map[player.combo_count])
		
	if player.is_on_floor() and InputBuffer.is_action_press_buffered("jump"):
		Transitioned.emit(self, "air", {do_jump = true})
		
	if player.get_input_direction() == 0:
		Transitioned.emit(self, "idle")
	else: 
		player.handle_horizontal_movement()
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
	
