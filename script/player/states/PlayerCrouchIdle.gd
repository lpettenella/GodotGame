extends PlayerState
class_name PlayerCrouchIdle

func enter(msg := {}):
	animated_sprite.play("crouch-idle")
	collision_shape.shape.size.y = 79.5
	collision_shape.position.y = 39.75
		
func physics_update(_delta: float):
	if player.just_hitted:
		Transitioned.emit(self, "hit")
		return
		
	#if player.dash_conditions():
		#Transitioned.emit(self, "dash")
		#return
		
	#if player.eat_conditions():
		#Transitioned.emit(self, "eat")
		#return
	
	if not player.is_on_floor() and not player.is_touching_ceiling():
		Transitioned.emit(self, "air")              
		if player.is_on_wall_check():
			Transitioned.emit(self, "wall")
	elif Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		Transitioned.emit(self, "crouchrun")
	elif Input.is_action_just_pressed("up") and not player.is_touching_ceiling():
		Transitioned.emit(self, "idle")
	elif InputBuffer.is_action_press_buffered("jump") and not player.is_touching_ceiling():
		Transitioned.emit(self, "air", {do_jump = true})
	elif Input.is_action_just_pressed("attack") and not player.is_touching_ceiling():
		player.combo_count = (player.combo_count + 1) % 3
		Transitioned.emit(self, player.melee_map[player.combo_count])

	player.velocity.x = lerp(player.velocity.x, 0.0, 0.3)
	player.move_and_slide()
	
func exit():
	collision_shape.shape.size.y = 125
	collision_shape.position.y = 17
