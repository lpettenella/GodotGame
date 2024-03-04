extends PlayerState
class_name PlayerWall

func enter(_msg := {}):
	if player.velocity.y < 0:
		animated_sprite.play("prewall")
	else: 
		animated_sprite.play("wall")
	
func physics_update(_delta: float):
	if player.just_hitted:
		Transitioned.emit(self, "hit")
		return
		
	handle_animation()
	
	if player.is_on_wall_check() and not player.is_on_wall_head():
		player.position.y += -125
		player.position.x += -69 * -player.facing 
		player.velocity.x = 0
		player.velocity.y = 0
		Transitioned.emit(self, "idle")
		return
	
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
	if not player.is_on_wall_check():
		Transitioned.emit(self, "air")
				
	if Input.is_action_just_pressed("jump"):
		player.jumped = false
		player.jump_timer = 0.0
		player.position.x -= 10 * player.facing
		player.flip_player(player.facing * -1)
		Transitioned.emit(self, "air", {do_jump_wall = true})
	
	player.handle_jump(_delta)
		
	player.move_and_slide()
	
func handle_animation():
	if player.velocity.y >= 0:
		if animated_sprite.animation != "wall":
			animated_sprite.play("wall")
		player.velocity.y = player.GRAVITY 
	elif player.velocity.y < 0:
		if animated_sprite.animation != "prewall":
			animated_sprite.play("prewall")
		player.velocity.y += player.GRAVITY

