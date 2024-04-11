extends CharacterBody2D

@export var hitParticle : PackedScene
@export var meat : PackedScene
@export var bullet: PackedScene
@export var drop_rate : int = 1
@export var health : int = 10
@export var fly: bool = false
@export var is_melee: bool = true
@export var is_range: bool = false
@export var frame_attack_hit = 3
@export var frame_handle_hit = 6
@export var can_born = false

const GRAVITY = 70
const SPEED = 250
const KNOCKBACK_SPEED = 200
const WAGGLE_DELAY_TIME = 2.0
const WAGGLE_TIME = 2.0
const UP = Vector2.UP

var direction = -1
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
var waggle_delay_timer = 0.0
var waggle_timer = 0.0
var its_waggle_time = false
var waggle_rand = 1
var waggle_dir = [1, -1]
var out_of_border = false
var raycast_pos
var hitted_from
var shooted = false

var shape_chase_radius

var instanced_meat = null
var instanced_bullet = null
var player_body = null
var dir_changed = false

func _ready():
	if can_born:
		state = "born"
	raycast_pos = $RayCast2D.position.x
	waggle_delay_timer = randf_range(0, WAGGLE_DELAY_TIME)
	randomize()
	shape_chase_radius = $ChaseArea/CollisionShape2D.shape.radius

func _physics_process(delta):
	$AnimatedSprite2D.play(state)
	$AttackArea.scale.x = direction
	$SearchArea.scale.x = direction
	$PositionToPlayer.scale.x = direction
	if direction == 1:
		$RayCast2D.position.x = raycast_pos
	else:
		$RayCast2D.position.x = -raycast_pos 

	get_children()
	if !fly:
		velocity.y += GRAVITY

	if direction == -1:
		$AnimatedSprite2D.set_flip_h(true)
	else: 
		$AnimatedSprite2D.set_flip_h(false)

	if await !$RayCast2D.is_colliding() and !dir_changed and is_on_floor():
		direction *= -1
		dir_changed = true
	if await $RayCast2D.is_colliding():
		dir_changed = false

	handle_states(delta)
	
func _on_AnimatedSprite_animation_finished():
	match($AnimatedSprite2D.animation):
		"attack":
			state = "run"
			$AttackDelay.start()
			shooted = false
		"death":
			after_death()
		"born":
			state = "idle"

func handle_states(delta):
	if state == "born":
		return
	if state == "death":
		handle_death()
		return
	if state == "hit":
		handle_hitted()
		return
	if state == "attack":
		handle_attack()
		return
	if attack_condition():
		state = "attack"
		return
	if player_body == null:
		waggle(delta)
	else:
		chase_player()
		
	move_and_slide()
	
func waggle(delta): 
	if its_waggle_time:
		state = "run"
		velocity.x = direction * 60
		waggle_timer += delta
		if waggle_timer >= WAGGLE_TIME:
			its_waggle_time = false
			waggle_timer = 0
	else: 
		state = "idle"
		waggle_delay_timer += delta
		velocity.x = 0
		if waggle_delay_timer >= WAGGLE_DELAY_TIME:
			its_waggle_time = true
			waggle_rand = randi() % 2
			direction = waggle_dir[waggle_rand]
			waggle_delay_timer = 0
	
func chase_player():
	if $StunTime.time_left > 0: return
	
	if player_body.position.x < position.x : direction = -1
	else : direction = 1
	
	if !fly:
		if near_player or !$RayCast2D.is_colliding():
			dir_changed = false
			state = "idle"
			velocity.x = 0
		else:
			state = "run"
			velocity.x = position.direction_to(player_body.position).x * SPEED
	if fly:
		if near_player:
			dir_changed = false
			state = "idle"
			velocity.x = 0
			velocity.y = 0
		else:
			state = "run"
			velocity.x = position.direction_to(player_body.position).x * SPEED
			velocity.y = position.direction_to(player_body.position).y * SPEED

func attack_condition():
	if is_melee:
		return (
			player_in_range and 
			!$AttackDelay.time_left > 0 and 
			!$StunTime.time_left > 0 and
			(is_on_floor() or fly)
		)
	if is_range:
		return (
			player_body != null and
			!$AttackDelay.time_left > 0 and 
			!$StunTime.time_left > 0
		)
		
func handle_hitted():
	if $KnockbackTime.time_left > 0: 
		knockback()
	
func knockback():
	velocity.x = KNOCKBACK_SPEED * my_random_number * hitted_from
	if !fly:
		velocity.y = -GRAVITY * 3
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	
func handle_attack():
	if is_melee:
		if player_could_be_hit and $AnimatedSprite2D.frame >= frame_attack_hit:
			player_body.get_damage(direction)
	if is_range:
#		velocity.x = lerp(velocity.x, 0.0, 0.3)
		shoot()
		
func shoot():
	if shooted:
		return
	$Marker2D.look_at(player_body.position)
	instanced_bullet = bullet.instantiate()
	instanced_bullet.position = $Marker2D.global_position
	instanced_bullet.velocity = player_body.position - instanced_bullet.position
	get_tree().current_scene.add_child(instanced_bullet)
	shooted = true

func handle_hit(from):
	if state == "death": return
	if state == "attack" and $AnimatedSprite2D.frame < frame_handle_hit and is_melee: return
	health -= 1
	my_random_number = randi() % 4 + 1
	if health <= 0:
		emit_particle()
		$KnockbackTime.start()
		state = "death"
		return
	state = "hit"
	hitted_from = from
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
	var particles = hitParticle.instantiate()
	particles.position.x = global_position.x + (-direction * 10)
	particles.position.y = global_position.y
	particles.scale.x = -direction
	particles.emitting = true
	get_tree().current_scene.add_child(particles)
	return
	
func drop_meat():
	instanced_meat = meat.instantiate()
	instanced_meat.position.y = global_position.y
	instanced_meat.position.x = global_position.x
	get_tree().current_scene.add_child(instanced_meat)
	
func _on_stun_time_timeout():
	state = "run"
			
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
		$ChaseArea/CollisionShape2D.shape.radius = shape_chase_radius * 2
		player_body = body
		
func _on_ChaseArea_body_exited(body):
	if body.name == "Player":
		$ChaseArea/CollisionShape2D.shape.radius = shape_chase_radius
		player_body = null
