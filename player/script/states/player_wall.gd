extends PlayerState
class_name PlayerWall

var wall_fx 
var gravity_fx
var offset_fx
var particles

var foot_step_timer = 0
const FOOT_STEP_DELAY = 0.085

@onready var foot_step = get_parent().get_node("FootStep")

func emit_particles():
	particles.position = player.get_node("WallArea").global_position
	particles.process_material.gravity.x = gravity_fx * player.facing 
	particles.emitting = true
	
	get_tree().current_scene.add_child(particles)

func enter(_msg := {}):
	foot_step_timer = 0
	foot_step.play()
	particles = player.wall_fx.instantiate()
	gravity_fx = particles.process_material.gravity.x
	offset_fx = particles.process_material.emission_shape_offset.y
	
	if player.velocity.y < 0:
		animated_sprite.play("prewall")
	else: 
		animated_sprite.play("wall")
	
func physics_update(_delta: float):
	emit_particles()
	handle_animation(_delta)
	
	if player.just_hitted:
		Transitioned.emit(self, "hit")
		return
		
	if player.dash_conditions():
		Transitioned.emit(self, "dash")
		return
	
	if player.is_on_wall_check() and not player.is_on_wall_head():
		if player.is_touching_ceiling_long():
			player.velocity.x = 0
			player.velocity.y = 0

			collision_shape.disabled = true
			crouch_collision.disabled = false
			
			print(player.get_node("WallChecker").global_position.y)

			var wall_checker_pos = player.get_node("WallChecker").global_position.y
			#high engineering >.>
			player.position.y += -16 - (int(wall_checker_pos) % 16)
			player.position.x += -16 * -player.facing
			Transitioned.emit(self, "crouchidle",  {from_wall_climb = true})
		#else: 
			##player.position.y += -125
			##player.position.x += -69 * -player.facing 
			#player.position.y += -48
			#player.position.x += -48 * -player.facing
			#Transitioned.emit(self, "idle")
			return
	
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
	if not player.is_on_wall_check():
		Transitioned.emit(self, "air")
				
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("down"):
			player.jumped = true	
		else:
			player.jumped = false
		player.jump_timer = 0.0
		player.position.x -= 10 * player.facing
		player.flip_player(player.facing * -1)
		Transitioned.emit(self, "air", {do_jump_wall = true})
	
	player.handle_jump(_delta)
	#player.velocity.y += player.GRAVITY
		
	player.move_and_slide()
	
func exit():
	foot_step.playing = false
	particles.emitting = false
	$Slide.playing = false
	
func handle_animation(_delta):
	if player.velocity.y >= 0:
		if not $Slide.playing:
			$Slide.play()
		if animated_sprite.animation != "wall":
			animated_sprite.play("wall")
		player.velocity.y = player.GRAVITY * 2
		particles.process_material.emission_shape_offset.y = -10
	elif player.velocity.y < 0:
		$Slide.playing = false
		handle_sound_effects(_delta)
		if animated_sprite.animation != "prewall":
			animated_sprite.play("prewall")
		player.velocity.y += player.GRAVITY
		particles.process_material.emission_shape_offset.y = 10
		
func handle_sound_effects(_delta):
	if foot_step_timer >= FOOT_STEP_DELAY:
		foot_step_timer = 0
		foot_step.play()
	else:
		foot_step_timer += _delta

