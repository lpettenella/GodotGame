extends CharacterBody2D

@export var max_health = 7
@export var bullet : PackedScene

const GRAVITY = 100
const SPEED = 600
const UP = Vector2.UP
const FALL_LIMIT = 1500
const JUMP_IMPULSE = 1100
const JUMP_TIMER_MAX = 0.2

@onready var health = max_health
signal health_changed

var direction = 1
var attack_impulse_cooldown = 0
var state = "idle"
var combo_count = -1
var queued_attack = false
var queued_jump = false
var prefall_finished = false
var first_jmp_atk = false
var can_eat = false
var meat_body = []
var actual_meat : CharacterBody2D
var jump_timer = 0.0
var jumped = false
var instanced_bullet
var shooted = false
var jumped_from_wall = false

var slide_on_wall_timer = 0.0

const melee_map = ["attack1", "attack2", "attack3"]
var all_attack = melee_map + ["jumpattack"] + ["shoot"]
const movement_map = ["idle", "run", "jump", "fall", "prefall", "jumpattack", "shoot", "wall", "climb"]

func _physics_process(delta):
#    if !is_on_wall_check():
	velocity.y += GRAVITY
	if velocity.y > FALL_LIMIT:
		velocity.y = FALL_LIMIT

	$AnimatedSprite2D.set_flip_h(direction != 1)
	$AttackArea.scale.x = direction
	$AirAttackArea.scale.x = direction
	$ShootArea.scale.x = direction
	$WallChecker.rotation_degrees = 90 * -direction

	handle_states(delta)
	
	if $AnimatedSprite2D.animation != state:
		$AnimatedSprite2D.play(state)
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	
func is_on_wall_check():
	return $WallChecker.is_colliding()

func handle_states(delta):
	if state == "damage" or state == "death":
		return
	if state == "eat":
		handle_eat()
		return
	if state in all_attack:
		handle_attack()
	if state in movement_map:
		if Input.is_action_just_pressed("attack"):
			start_attack()
			return
		if Input.is_action_just_pressed("shoot"):
			start_shoot()
			return
		if Input.is_action_just_pressed("eat"):
			start_eat()
			return
		if Input.is_action_just_pressed("jump"):
			jumped_from_wall = is_on_wall_check()
			if jumped_from_wall: 
				position.x += 10 * -direction
				direction =- direction
		if Input.is_action_pressed("jump"):
			jump_timer += delta
			handle_jump()
		if Input.is_action_just_released("jump"):
			jumped = true
			jump_timer = 0.0
			jumped_from_wall = false
		if Input.is_action_pressed("right"):
			handle_movement("right", delta)
		elif Input.is_action_pressed("left"):
			handle_movement("left", delta)
		elif Input.is_action_pressed("up"):
			handle_movement("up", delta)
		else: handle_movement("stop", delta)
				
func start_eat():
	if !is_on_floor() or !can_eat or health == max_health: return
	actual_meat = meat_body.back()
	state = "eat"
		
func start_attack():
	$AttackImpulse.start()
	if is_on_floor():
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			velocity.x = 500 * direction
		combo_count = (combo_count + 1) % 3
		state = melee_map[combo_count]
		$AttackComboDelay.stop()
	else:
#		first_jmp_atk = !first_jmp_atk
		state = "jumpattack"
		
func start_shoot(): 
	if !shooted: 
		state = "shoot"
		$ShootDelay.start()
		
func handle_eat():
	velocity = position.direction_to(actual_meat.position) * SPEED
		
func handle_falling(): 
	if state != "fall":
		state = "prefall"
		
func handle_jump():
	if jumped_from_wall:
		velocity.x = SPEED * 1.5 * direction
	if jump_timer >= JUMP_TIMER_MAX or jumped: 
		return
	velocity.y = -JUMP_IMPULSE

func handle_movement(movement, delta):
	if state == "jumpattack":
		if first_jmp_atk:
			velocity.x = lerp(velocity.x, 0.0, 0.3)
			velocity.y = lerp(velocity.y, 0.0, 0.3)
		return
		
	if state == "shoot":
		velocity.y = lerp(velocity.y, 0.0, 0.7)
		return
		
	if !is_on_wall_check() and !jumped_from_wall:
		if movement == "stop":
			velocity.x = lerp(velocity.x, 0.0, 0.3)
		elif movement == "right": 
			velocity.x = SPEED
			direction = 1
		elif movement == "left":
			velocity.x = -SPEED
			direction = -1
			
	if is_on_wall_check():
		slide_on_wall_timer += delta
		jumped = false
		if movement == "up":
			state = "climb"
			$AnimatedSprite2D.play("climb")
			velocity.y = -SPEED/1.5
		else:
			state = "wall"
			velocity.x = 0
			if slide_on_wall_timer <= 0.2:
				velocity.y = lerp(velocity.y, 0.3, 0.1)
			else: velocity.y = 0
		return
	else: slide_on_wall_timer = 0.0
		
	if is_on_floor():
		first_jmp_atk = true
		jumped = false
		jumped_from_wall = false
		if movement != "stop": 
			state = "run"
		else: state = "idle"
	if !is_on_floor(): 
		if velocity.y <= 0:
			state = "jump"
		elif velocity.y > 0:
			handle_falling()

func handle_attack():
	if state == "jumpattack":
		$AirAttackArea/CollisionShape2D.disabled = false
		return
	if state in melee_map:
		handle_melee()
	if state == "shoot":
		handle_shoot()
			
func handle_melee():
	var delay_frame_collision = 3
	if Input.is_action_just_pressed("attack"):
		queued_attack = true
	if state == melee_map[0] and $AnimatedSprite2D.frame == delay_frame_collision:
		$AttackArea/CollisionShape2D.disabled = false
	elif state != melee_map[0]:
		$AttackArea/CollisionShape2D.disabled = false
		
func handle_shoot():
	var shootColl = $ShootArea.get_child(0)
	if $AnimatedSprite2D.frame == 2 and !shooted:
		frame_freeze(0.1, 0.3)
#		$Camera2D/ScreenShake.start(Callable(0.1,12).bind(15),0) todo()
	if $AnimatedSprite2D.frame == 2 and !shooted:
		shooted = true
#		frame_freeze(0.1, 0.4)
		instanced_bullet = bullet.instantiate()
		instanced_bullet.position.y = shootColl.global_position.y
		instanced_bullet.position.x = shootColl.global_position.x
		instanced_bullet.init(direction)
		get_tree().current_scene.add_child(instanced_bullet)
		handle_knockback(700)
	
func handle_knockback(amount = 100):
	$KnockbackTime.start()
	velocity.x = amount * (direction * -1)
	
func damage_knockback(direction):
	$KnockbackTime.start()
	velocity.x = 300 * (direction)
	
func handle_death(direction):
	frame_freeze(0.1, 0.6)
	disable_atk_collision()
	state = "death"
	$DeathTime.start()
	velocity.x = 100 * (direction)
	
func disable_atk_collision(value = "both"):
	match(value):
		"both":
			$AttackArea/CollisionShape2D.disabled = true
			$AirAttackArea/CollisionShape2D.disabled = true
		"floor":
			$AttackArea/CollisionShape2D.disabled = true
		"air":
			$AirAttackArea/CollisionShape2D.disabled = true
	
func get_damage(direction):
	if $InvicibilityFrames.time_left > 0:
		return
	health -= 1
	if health <= 0:
		handle_death(direction)
		return
	state = "damage"
	frame_freeze(0.1, 0.3)
	damage_knockback(direction)
	emit_signal("health_changed", health)
	disable_atk_collision()
	$DamageTime.start()
	$InvicibilityFrames.start()
	modulate.a = 0.5
	
func gain_health(qty):
	if health == max_health: return
	health += qty
	emit_signal("health_changed", health)
	
func handle_post_eat():
	state = "idle"
	var meat_to_eat = meat_body.pop_at(-1)
	if meat_to_eat != null:
		meat_to_eat.get_eaten()
		gain_health(1)

func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
		
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite2D.animation in melee_map:
		disable_atk_collision("floor")
		if queued_attack:
			start_attack()
			queued_attack = false
		elif queued_jump:
			handle_jump()
			queued_jump = false
		else:
			state = "idle"
			$AttackComboDelay.start()
	match($AnimatedSprite2D.animation):
		"prefall": 
			state = "fall"
		"jumpattack":
			disable_atk_collision("air")
			first_jmp_atk = false
			state = "fall"
		"eat":
			handle_post_eat()
		"death": 
			get_tree().reload_current_scene()
		"shoot":
			state = "idle"

func _on_AttackComboDelay_timeout():
	combo_count = -1

func _on_AttackImpulse_timeout():
	velocity.x = lerp(velocity.x, 0.0, 0.2)
	
func _on_KnockbackTime_timeout():
	if state == "shoot":
		velocity.x = 0
	else: velocity.x = lerp(velocity.x, 0.0, -0.2)
	
func _on_DeathTime_timeout():
	velocity.x = lerp(velocity.x, 0.0, direction * 0.2)
	
func _on_DamageTime_timeout():
	state = "idle"
	
func _on_AttackArea_body_entered(body: CharacterBody2D):
	if body.has_method("handle_hit") and !$AttackArea/CollisionShape2D.disabled:
		handle_knockback()
		body.handle_hit(direction)
		$Camera2D/ScreenShake.start()

func _on_AirAttackArea_body_entered(body):
	if body.has_method("handle_hit") and !$AirAttackArea/CollisionShape2D.disabled:
		handle_knockback()
		body.handle_hit(direction)
		$Camera2D/ScreenShake.start()

func _on_InvicibilityFrames_timeout():
	modulate.a = 1

func _on_FeetArea_body_entered(body):
	is_on_floor()
	if body.has_method("get_eaten"):
		can_eat = true
		meat_body.append(body)

func _on_FeetArea_body_exited(body):
	if body.has_method("get_eaten"):
		meat_body.erase(body)
		if meat_body.is_empty(): can_eat = false

func _on_ShootDelay_timeout():
	shooted = false
