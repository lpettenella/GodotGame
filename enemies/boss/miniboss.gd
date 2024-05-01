extends CharacterBody2D

@export var player: CharacterBody2D
@export var health: int = 10
@export var point_for_dive : Node2D

const GRAVITY = 20
const SPEED = 120
const FOLLOW_TIME = 3.0
const FOLLOW_DELAY_NEAR = 5.0
const FOLLOW_DELAY = 1.5

@export var state = "idle"
@export var can_die = true

var player_in_range = false
var player_in_range_up = false
var player_is_near = false
var can_catch_player = false
var follow_timer = 0.0
var follow_delay_timer = 0.0
var is_follow_time = true
var direction = 1

func _physics_process(delta):
	#if velocity.y >= SPEED:
		#velocity.y = SPEED
	#else:
		#velocity.y += GRAVITY
	#
	$AttackArea.scale.x = direction
	
	if $HitRed.time_left > 0:
		$AnimatedSprite2D.modulate = Color.CRIMSON
	else: 
		$AnimatedSprite2D.modulate.r = 1.0
		$AnimatedSprite2D.modulate.g = 1.0
		$AnimatedSprite2D.modulate.b = 1.0
	
	if direction == -1:
		$AnimatedSprite2D.set_flip_h(true)
	else: 
		$AnimatedSprite2D.set_flip_h(false)
	
	if state != $AnimatedSprite2D.animation:
		$AnimatedSprite2D.play(state)
	
	handle_states(delta)
	
	move_and_slide()
	
func handle_states(delta):
	if state == "fall":
		player.visible = false
		if velocity.y >= 300:
			velocity.y = 300
		else:
			velocity.y += GRAVITY
		if is_on_floor():
			player.visible = true
			state = "down"
		return
	if state == "death":
		return
	if state == "catch":
		if $AnimatedSprite2D.frame == 3:
			player.visible = false
			player.frame_freeze(0.1, 2)
		if $AnimatedSprite2D.frame >= 3:
			player.velocity = player.position.direction_to(position) * SPEED
		if not $AnimatedSprite2D.is_playing():
			player.get_node("CollisionShape2D").disabled = true
			player.get_node("WallChecker").enabled = false
			$CollisionShape2D.disabled = true
			velocity.y = SPEED
		return
	if state != "attack":
		if position.x > player.position.x : direction = 1
		else: direction = -1
	if state == "wait_for_player":
		position.x = point_for_dive.position.x
		if can_catch_player:
			player.freezed = true
			if player.is_on_floor(): 
				await get_tree().create_timer(1.0).timeout
				state = "catch"
				z_index = 1
		return
	if state == "down": return
	if is_follow_time:
		if follow_timer >= FOLLOW_TIME:
			state = "up"
			is_follow_time = false
			velocity.x = 0
			follow_timer = 0.0
			return
		follow_timer += delta
		velocity.x = position.direction_to(player.position).x * SPEED
		state = "pre-up"
		return
	else: 
		follow_delay_timer += delta
		if ((player_is_near and follow_delay_timer >= FOLLOW_DELAY_NEAR) or
			(!player_is_near and follow_delay_timer >= FOLLOW_DELAY)):
			is_follow_time = true
			state = "down"
			follow_delay_timer = 0.0
	if state == "attack":
		handle_attack()
		return
	if state == "up":
		if player_in_range_up:
			player.get_damage(direction)
		return
	if player_in_range:
		start_attack()
		return
		
func handle_attack():
	if $AnimatedSprite2D.frame >= 4 and player_in_range:
		player.get_damage(direction)
		
func start_attack():
	if $AttackDelay.time_left > 0: return
	$AttackDelay.start()
	state = "attack"

func handle_hit(from):
	if state != "idle" and state != "hit": return
	health -= 1
	state = "hit"
	$HitRed.start()
	
	print("hitted")
#	if state == "death": return
#	if state == "attack" and $AnimatedSprite2D.frame < 6 and melee: return
#	health -= 1
#	my_random_number = randi() % 4 + 1
	if health <= 0:
		state = "death" if can_die else "wait_for_player"
		return
#	state = "hit"
#	hitted_from = from
#	$KnockbackTime.start()
#	$StunTime.start()
#	emit_particle()
	
func _on_animated_sprite_2d_animation_finished():
	match($AnimatedSprite2D.animation):
		"attack", "up":
			state = "idle"
		"down":
			state = "pre-up"

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_attack_area_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		
func _on_near_area_body_entered(body):
	if body.name == "Player":
		player_is_near = true

func _on_near_area_body_exited(body):
	if body.name == "Player":
		player_is_near = false

func _on_attack_area_up_body_entered(body):
	if body.name == "Player":
		player_in_range_up = true

func _on_attack_area_up_body_exited(body):
	if body.name == "Player":
		player_in_range_up = false

func _on_catch_area_body_entered(body):
	if body.name == "Player" and state == "wait_for_player":
		can_catch_player = true

func _on_near_area_area_entered(area):
	print(area.name)
	if area.name == "NextLevel":
		get_tree().change_scene_to_file("res://levels/lab_levels/level_lab.tscn")
