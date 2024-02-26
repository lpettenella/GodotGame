extends PlayerState
class_name PlayerRun

func enter(_msg := {}):
	player.get_node("AnimatedSprite2D").play("run")
	
func physics_update(_delta: float):
	if not player.is_on_floor():
		Transitioned.emit(self, "air")
		if player.is_on_wall_check():
			Transitioned.emit(self, "wall")
		
	if player.is_on_floor() and Input.is_action_pressed("jump"):
		Transitioned.emit(self, "air", {do_jump = true})
		
	if Input.is_action_just_pressed("attack"):
		player.combo_count = (player.combo_count + 1) % 3
		Transitioned.emit(self, player.melee_map[player.combo_count])
		return
		
	if player.get_input_direction() == 0:
		Transitioned.emit(self, "idle")
	else: 
		player.handle_horizontal_movement()
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
	
