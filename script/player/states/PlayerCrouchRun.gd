extends PlayerState
class_name PlayerCrouchRun

var to_crouch = false

func enter(_msg := {}):
	animated_sprite.play("crouch-run")
	collision_shape.disabled = true
	crouch_collision.disabled = false
	
func physics_update(_delta: float):
	if player.just_hitted:
		Transitioned.emit(self, "hit")
		return
		
	#if player.dash_conditions():
		#Transitioned.emit(self, "dash")
		#return
		#
	#if player.eat_conditions():
		#Transitioned.emit(self, "eat")
		#return
		
	if not player.is_on_floor():
		Transitioned.emit(self, "air")
		if player.is_on_wall_check():
			Transitioned.emit(self, "wall")
	elif Input.is_action_just_pressed("attack") and not player.is_touching_ceiling():
		player.combo_count = (player.combo_count + 1) % 3
		Transitioned.emit(self, player.melee_map[player.combo_count])
	elif Input.is_action_just_pressed("up") and not player.is_touching_ceiling():
		if is_equal_approx(player.velocity.x, 0.0):
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
		return
	elif player.is_on_floor() and InputBuffer.is_action_press_buffered("jump") and not player.is_touching_ceiling():
		Transitioned.emit(self, "air", {do_jump = true})
		
	if player.get_input_direction() == 0:
		to_crouch = true
		Transitioned.emit(self, "crouchidle")
	else: 
		player.velocity.x = player.SPEED / 2 * player.facing
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
func exit():
	collision_shape.disabled = false
	crouch_collision.disabled = true
	
	
