extends PlayerState 
class_name PlayerAir

const WALL_IMPULSE_TIME = 0.15
var wall_impulse_timer = 0.0

var jump = false
var from_wall = false

var jump_fx 

func emit_particles():
	var particles = player.jump_fx.instantiate()
	#particles.position.x = global_position.x + (-direction * 10)
	#particles.position.y = global_position.y
	#particles.scale.x = -direction
	particles.position = player.get_node("FeetArea").global_position
	print(player.get_node("FeetArea").position)
	particles.emitting = true
	get_tree().current_scene.add_child(particles)
	print("emitting jump particles")
	return

func enter(msg := {}):
	animated_sprite.play("jump")
	if msg.has("do_jump_wall"):
		from_wall = true
	if msg.has("do_jump"):
		emit_particles()
		jump = true
		
func physics_update(_delta: float):
	if jump or from_wall:
		player.handle_jump(_delta)
		
	if player.jumped == true: jump = false
		
	if player.just_hitted:
		player.jumped = true
		Transitioned.emit(self, "hit")
		return
		
	if player.dash_conditions():
		Transitioned.emit(self, "dash")
		return
		
	if player.is_on_wall_check():
		Transitioned.emit(self, "wall")
		return
		
	if InputBuffer.is_action_press_buffered("attack"):
		Transitioned.emit(self, "airattack")
		return
		
	if player.is_on_floor() and not jump:
		if is_equal_approx(player.velocity.x, 0.0):
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
		return
			
	if player.velocity.y > 0 and not animated_sprite.animation in ["fall", "prefall"]:
		animated_sprite.play("prefall")
	if animated_sprite.animation == "prefall" and not animated_sprite.is_playing():
		animated_sprite.play("fall")
		
	if from_wall:
		wall_impulse_timer += _delta
		if wall_impulse_timer < WALL_IMPULSE_TIME:
		#if Input.is_action_pressed("jump"):
			player.velocity.x = player.SPEED * 1.5 * player.facing
		else:
			player.handle_horizontal_movement(1.5)
	else:
		player.handle_horizontal_movement()
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
func exit():
	jump = false
	from_wall = false
	wall_impulse_timer = 0.0

