extends CharacterBody2D

@export var max_health = 7
@export var bullet : PackedScene
@export var dash_fx: PackedScene

const GRAVITY = 100
const SPEED = 600
const UP = Vector2.UP
const FALL_LIMIT = 1500
const JUMP_IMPULSE = 1100
const JUMP_TIMER_MAX = 0.2
const SLIDE_ON_WALL_TIME = 0.5
const STAY_ON_WALL_TIME = 1.0
const CLIMB_TIME = 1.0
const SPEED_IMPULSE = 50

@onready var health = max_health
signal health_changed

var direction = 1
var attack_impulse_cooldown = 0
var state = "idle"
var combo_count = -1
var queued_attack = false
var queued_jump = false
var first_jmp_atk = false
var can_eat = false
var meat_body = []
var actual_meat : CharacterBody2D
var jump_timer = 0.0
var jumped = false
var instanced_bullet
var shooted = false
var jumped_from_wall = false
var jump_just_released = false

var slide_on_wall_timer = 0.0
var stay_on_wall_timer = 0.0
var climb_on_wall_timer = 0.0

const melee_map = ["attack1", "attack2", "attack3"]
const shoot_map = ["shoot-i", "shoot-r"]
var all_attack = melee_map + ["jumpattack"] + shoot_map
const movement_map = ["idle", "run", "after-run", "jump", "fall", "prefall", "jumpattack", "shoot-i", "shoot-r", "wall", "prewall", "climb"]

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
	$WallCheckerHead.rotation_degrees = 90 * -direction

	handle_states(delta)
	
	#if Input.is_action_pressed("left"): 
		#$AnimatedSprite2D.play("run")
		#state = "run"
		#velocity.x = -SPEED
		#direction = -1
	#elif Input.is_action_pressed("right"): 
		#$AnimatedSprite2D.play("run")
		#state = "run"
		#velocity.x = SPEED
		#direction = 1
#
	#else:
		#if state == "run": state = "after-run" 
		#elif state != "after-run": state = "idle"
		#velocity.x = lerp(velocity.x, 0.0, 0.3)
	
	if $AnimatedSprite2D.animation != state:
		$AnimatedSprite2D.play(state)
		
	set_velocity(velocity)
	set_up_direction(UP)
	move_and_slide()
	
func is_on_wall_check():
	return $WallChecker.is_colliding() and !is_on_floor()
	
func is_on_wall_head():
	return $WallCheckerHead.is_colliding()

func handle_states(delta):
	if Input.is_action_just_released("jump"):
		jumped = true
		jump_timer = 0.0
		jumped_from_wall = false
		jump_just_released = true
	if state == "damage" or state == "death":
		return
	if state == "dash":
		handle_dash()
		return
	if state in all_attack:
		handle_attack()
	if state == "eat":
		handle_eat()
		return
	if state in movement_map:
		if Input.is_action_just_pressed("attack"):
			start_attack()
			return
		if Input.is_action_just_pressed("dash"):
			start_dash()
			return
		if Input.is_action_just_pressed("shoot"):
			handle_shoot()
#			return
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
			handle_jump(Input.is_action_pressed("down"))

		if Input.is_action_pressed("right"):
			handle_movement("right", delta)
		elif Input.is_action_pressed("left"):
			handle_movement("left", delta)
		else: handle_movement("stop", delta)
				
func start_dash():
	if $DashDelay.time_left > 0: return
	state = "dash"
	$DashDelay.start()
	$DashTime.start()
	$RollInvFrames.start()
	
	if is_on_wall_check():
		position.x += 10 * -direction
		direction =- direction
	
	var instanced_dashfx = dash_fx.instantiate()
	instanced_dashfx.position.y = global_position.y
	instanced_dashfx.position.x = global_position.x
	instanced_dashfx.init(direction)
	get_tree().current_scene.add_child(instanced_dashfx)
				
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
		jumped = true
		
func start_shoot(): 
	if !shooted: 
		if velocity.x == 0:
			state = "shoot-i"
		else: state = "shoot-r"
		$ShootDelay.start()

func handle_dash():		
	velocity.y = 0
	if $DashTime.time_left > 0:
		velocity.x += 200 * direction
#	elif Input.is_action_just_pressed("jump") and is_on_floor():
#		state = "idle"
	
func handle_eat():
	velocity = position.direction_to(actual_meat.position) * SPEED
		
func handle_falling(): 
	if state != "fall":
		state = "prefall"
	jumped = true
		
func handle_jump(is_down_pressed = false):
	if jumped_from_wall:
		velocity.x = SPEED * 1.3 * direction
	if jump_timer >= JUMP_TIMER_MAX or jumped: 
		return
	if is_down_pressed:
		velocity.y = JUMP_IMPULSE / 1.3
	else: velocity.y = -JUMP_IMPULSE

func handle_movement(movement, delta):
	if state == "jumpattack":
		#if first_jmp_atk:
			#velocity.x = lerp(velocity.x, 0.0, 0.3)
		velocity.y = lerp(velocity.y, 0.0, 0.1)
		return
		
	if !is_on_wall_check() and !jumped_from_wall:
		if movement == "stop":
			if jump_just_released: 
				velocity.x = lerp(velocity.x, 0.0, 0.03)
			else:
				velocity.x = lerp(velocity.x, 0.0, 0.3)
		elif movement == "right": 
			if is_on_floor():
				velocity.x = SPEED
			else:
				velocity.x += SPEED_IMPULSE
				if velocity.x >= SPEED:
					velocity.x = SPEED
			direction = 1
		elif movement == "left":
			if is_on_floor():
				velocity.x = -SPEED
			else:
				velocity.x += -SPEED_IMPULSE
				if velocity.x <= -SPEED:
					velocity.x = -SPEED
			direction = -1
			
	if state in shoot_map:
#		velocity.y = lerp(velocity.y, 0.0, 0.7)
		return
		
	if is_on_wall_check() and !is_on_wall_head():
		position.y += -125
		position.x += -69 * -direction 
		velocity.x = 0
		velocity.y = 0
	if is_on_wall_check() and is_on_wall_head():
		slide_on_wall_timer += delta
		stay_on_wall_timer += delta
		climb_on_wall_timer += delta
		
		jumped = false
		jump_just_released = false
		if Input.is_action_pressed("up") and climb_on_wall_timer <= SLIDE_ON_WALL_TIME + CLIMB_TIME:
			state = "climb"
			velocity.y = -SPEED/1.5
		else:
			velocity.x = 0
			if Input.is_action_pressed("down") and slide_on_wall_timer >= SLIDE_ON_WALL_TIME:
				state = "wall"
				velocity.y = lerp(velocity.y, 1.0, 0.1)
			elif slide_on_wall_timer <= SLIDE_ON_WALL_TIME and velocity.y < 0:
				state = "prewall"
				velocity.y = lerp(velocity.y * 1.2, 0.0, 0.15)
			elif stay_on_wall_timer <= STAY_ON_WALL_TIME + SLIDE_ON_WALL_TIME + CLIMB_TIME:
				state = "wall"
				velocity.y = 0
			else: velocity.y = lerp(velocity.y, 1.0, 0.3)
		return
	else: 
		slide_on_wall_timer = 0.0
		stay_on_wall_timer = 0.0
		climb_on_wall_timer = 0.0
		
	if is_on_floor():
		first_jmp_atk = true
		jumped = false
		jumped_from_wall = false
		jump_just_released = false
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
#	if state in shoot_map:
#		handle_shoot()
			
func handle_melee():
	var delay_frame_collision = 3
	if Input.is_action_just_pressed("attack"):
		queued_attack = true
	if state == melee_map[0] and $AnimatedSprite2D.frame == delay_frame_collision:
		$AttackArea/CollisionShape2D.disabled = false
	elif state != melee_map[0]:
		$AttackArea/CollisionShape2D.disabled = false
		
func handle_shoot():
#	if $AnimatedSprite2D.frame == 2 and !shooted:
##		frame_freeze(0.1, 0.3)
#		$Camera2D/ScreenShake.start()
#	if $AnimatedSprite2D.frame == 2 and !shooted:
	if !shooted:
		$ShootDelay.start()
		shooted = true  
		if velocity.x == 0:
			state = "shoot-i"
		else: state = "shoot-r"
		var shootColl = $ShootArea.get_child(0)
#		frame_freeze(0.1, 0.4)
		instanced_bullet = bullet.instantiate()
		instanced_bullet.position.y = shootColl.global_position.y
		instanced_bullet.position.x = shootColl.global_position.x
		instanced_bullet.init(direction)
		get_tree().current_scene.add_child(instanced_bullet)
#		handle_knockback(700)
	
func handle_knockback(amount = 100):
	$KnockbackTime.start()
	velocity.x = amount * (direction * -1)
	
func damage_knockback(direction):
	$KnockbackTime.start()
	velocity.x = 300 * (direction)
	
func handle_death(direction):
	frame_freeze(0.1, 0.6)
#	disable_atk_collision()
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
	if $InvicibilityFrames.time_left > 0 or $RollInvFrames.time_left > 0:
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
	disable_atk_collision()
	if $AnimatedSprite2D.animation in melee_map:
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
		"run": state = "after-run"
		"after-run": state = "idle"
		"prefall": 
			state = "fall"
		"jumpattack":
			first_jmp_atk = false
			state = "fall"
		"eat":
			handle_post_eat()
		"death": 
			get_tree().reload_current_scene()
		"shoot-i":
			state = "idle"
		"shoot-r", "dash":
			state = "run"

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
