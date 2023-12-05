extends CharacterBody2D

@export var hitParticle : PackedScene
@export var meat : PackedScene
@export var drop_rate : int
@export var health : int
@export var flying: bool

const GRAVITY = 70
const SPEED = 250
const KNOCKBACK_SPEED = 200
const IDLE_MOV_DELAY = 2.0
const WAGGLE_TIME = 2.0
const UP = Vector2.UP

var direction = -1
var motion = Vector2()
var state = "idle"
var rng = RandomNumberGenerator.new()
var my_random_number = 0

var knockback_time = false
var stun_time = false
var can_attack = false
var attack_delay = false
var dropped = false
var player_in_range = false
var player_could_be_hit = false
var near_player = false
var idle_mov_delay_timer = 0.0
var waggle_timer = 0.0
var waggle = false
var waggle_rand = 1
var waggle_dir = [1, -1]

var instanced_meat = null
var player_body = null

func _ready():
	idle_mov_delay_timer = randf_range(0, IDLE_MOV_DELAY)
	randomize()

func _physics_process(delta):
	$AnimatedSprite2D.play(state)
	$AttackArea.scale.x = direction
	$SearchArea.scale.x = direction
	$PositionToPlayer.scale.x = direction

	if !flying:
		motion.y += GRAVITY
	
	if direction == -1:
		$AnimatedSprite2D.set_flip_h(true)
	else: 
		$AnimatedSprite2D.set_flip_h(false)
		
	handle_states(delta)
	
func handle_states(delta):
	if state == "death":
		handle_death()
		return
		
	if $KnockbackTime.time_left > 0: 
		knockback()
		return
		
	if player_in_range:
		if !$AttackDelay.time_left > 0 and !$StunTime.time_left > 0:
			handle_attack()
			return
			
	if state == "attack": 
		return
		
	if state == "idle":
		idle_mov_delay_timer += delta
		if idle_mov_delay_timer >= IDLE_MOV_DELAY:
			idle_mov_delay_timer = 0
			waggle_rand = randi() % 2
			waggle = true
	
	if waggle: 
		waggle(delta)
	
	if !waggle:
		waggle = false
		if !near_player: 
			state = "run"
			chase_player()
		else: state = "idle" 
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity
	
	
func chase_player():
	if $StunTime.time_left > 0: return
	if player_body:
		motion.x = position.direction_to(player_body.position).x * SPEED
		if flying:
			motion.y = position.direction_to(player_body.position).y * SPEED
		if player_body.position.x < position.x : direction = -1
		else : direction = 1
	else: 
		motion.x = 0
		state = "idle"
		
func waggle(delta):
	state = "run"
	motion.x = waggle_dir[waggle_rand] * 60
	direction = waggle_dir[waggle_rand]
	waggle_timer += delta
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity
	if waggle_timer >= WAGGLE_TIME:
		waggle_timer = 0.0
		waggle = false
		state = "idle"
		motion.x = 0
	
func knockback():
	motion.x = -KNOCKBACK_SPEED * my_random_number * direction
	if flying: 
		motion.y = 0
	else: motion.y = -GRAVITY * 3
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()

#func handle_direction():
#	var playerposition = get_node("/root/Level1/Player").position
#	if (playerposition.x < get_position().x):
#		direction = -1
#	else: direction = 1
	
func handle_attack():
	state = "attack"
	if player_could_be_hit and $AnimatedSprite2D.frame >= 3:
		player_body.get_damage(direction)
		
func handle_hit():
	if state == "death": return
	if state == "attack" and $AnimatedSprite2D.frame < 6: return
	health -= 1
	my_random_number = randi() % 4 + 1
	if health <= 0:
		emit_particle()
		$KnockbackTime.start()
		state = "death"
		return
	state = "hit"
	$KnockbackTime.start()
	$StunTime.start()
	emit_particle()
	
func handle_death():
	if dropped : return
	var random = randi() % drop_rate + 1
	dropped = true
	if random == 1: drop_meat()
	
func after_death(): 
	if instanced_meat:
		instanced_meat.modulate.a = 1
	queue_free()
	
func emit_particle():
	var particle = hitParticle.instantiate()
	particle.position = global_position
	particle.scale.x = -direction
	particle.emitting = true
	get_tree().current_scene.add_child(particle)
	
func drop_meat():
	instanced_meat = meat.instantiate()
	instanced_meat.position.y = global_position.y
	instanced_meat.position.x = global_position.x
	get_tree().current_scene.add_child(instanced_meat)
	
func _on_StunTime_timeout():
	state = "run"
		
func _on_AnimatedSprite_animation_finished():
	match($AnimatedSprite2D.animation):
		"attack":
			state = "run"
			$AttackDelay.start()
		"death":
			after_death()
			
func _on_SearchArea_body_entered(body):
	if body.name == "Player":
		player_in_range = true
	
func _on_SearchArea_body_exited(body):
	if body.name == "Player":
		player_in_range = false
	
func _on_AttackArea_body_entered(body):
	if body.name == "Player":
		player_could_be_hit = true
	
func _on_AttackArea_body_exited(body):
	if body.name == "Player":
		player_could_be_hit = false
	
func _on_PositionToPlayer_body_entered(body):
	if body.name == "Player":
		near_player = true
	
func _on_PositionToPlayer_body_exited(body):
	if body.name == "Player":
		near_player = false
	
func _on_ChaseArea_body_entered(body):
	if body.name == "Player":
		$ChaseArea/CollisionShape2D.shape.radius = 800
		player_body = body

func _on_ChaseArea_body_exited(body):
	if body.name == "Player":
		$ChaseArea/CollisionShape2D.shape.radius = 450
		player_body = null
