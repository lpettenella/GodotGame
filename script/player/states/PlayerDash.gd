extends PlayerState
class_name PlayerDash

var dash_vector = Vector2(1,1).normalized()
var dash_time : Timer
var ghost_time : Timer
var dash_fx 

func enter(_msg := {}):
	animated_sprite.play("dash")
	dash_vector = player.get_input_vector()
	if dash_vector == Vector2(0, 0).normalized():
		dash_vector = Vector2(player.facing, 0).normalized()
		
	dash_time = player.get_node("DashTime")
	dash_time.start()
	
	ghost_time = player.get_node("GhostTime")
	ghost_time.start()
	
	player.add_ghost()
	
	dash_fx = player.get_node("GPUParticles2D")
	dash_fx.emitting = true

func physics_update(_delta: float):
	if dash_time.time_left == 0:
		if not player.is_on_floor():
			Transitioned.emit(self, "air")
		elif player.get_input_direction() == 0:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "run")
		return
	
	player.velocity = player.SPEED * 3 * dash_vector
	
	player.move_and_slide()
	
func exit():
	ghost_time.stop()
	player.velocity.y = lerp(player.velocity.y, 0.0, 0.5)
	dash_fx.emitting = false
