extends PlayerState
class_name PlayerAir

const WALL_IMPULSE_TIME = 0.15
var wall_impulse_timer = 0.0

var jump = false
var from_wall = false

func enter(msg := {}):
	animated_sprite.play("jump")
	if msg.has("do_jump_wall"):
		from_wall = true
		
func physics_update(_delta: float):
	player.handle_jump(_delta)
	
	if player.is_on_floor():
		player.jump_timer = 0.0
		player.jumped = false
		if is_equal_approx(player.velocity.x, 0.0):
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
		return
		
	if player.is_on_wall_check():
		Transitioned.emit(self, "wall")
		return
		
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "airattack")
		return
			
	if player.velocity.y > 0 and animated_sprite.animation != "fall":
		animated_sprite.play("prefall")
		
	if from_wall:
		wall_impulse_timer += _delta
		if wall_impulse_timer < WALL_IMPULSE_TIME:
			player.velocity.x = player.SPEED * player.facing * 1.5
		else:
			player.handle_horizontal_movement(1.5)
	else:
		player.handle_horizontal_movement()
		
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
func exit():
	from_wall = false
	wall_impulse_timer = 0.0
