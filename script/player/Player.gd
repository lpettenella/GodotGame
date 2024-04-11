extends CharacterBody2D
class_name Player

@export var max_health = 7
@export var bullet : PackedScene
@export var ghost : PackedScene
@export var screenShake : Node
@export var jump_fx : PackedScene

@onready var health = max_health
signal health_changed

const GRAVITY = 100
const SPEED = 600
const UP = Vector2.UP
const FALL_LIMIT = 1500
const JUMP_IMPULSE = 1100
const JUMP_TIMER_MAX = 0.2
const SLIDE_ON_WALL_TIME = 0.5
const STAY_ON_WALL_TIME = 1.0
const CLIMB_TIME = 1.0
const SPEED_IMPULSE = 70

const melee_map = ["attack1", "attack2", "attack3"]
var combo_count = -1
var queued_attack = false
var can_eat = false

var attacked = false
var dashed = false
@export var can_dash = false
var jumped = false
var jump_timer = 0.0
var facing = 1
var just_hitted = false
var damage_from = 1
var freezed = false
var can_interact_with = false
var interactable_obj = null
@export var last_checkpoint : Area2D

# dash
var dash_count = 0
@export var max_dash = 0
var dash_timeout = false

# meat
var meat_body = []
var actual_meat : CharacterBody2D
	
func _physics_process(delta):
	if velocity.y > FALL_LIMIT:
		velocity.y = FALL_LIMIT
		
	if can_interact_with and Input.is_action_just_pressed("interact"):
		interactable_obj.do_interact()

func _ready():
	$TerrainCheckpointDetector.Obstacle.connect(on_obstacle)
	$TerrainCheckpointDetector.Checkpoint.connect(on_checkpoint)
	
func on_obstacle():
	get_damage(facing * -1)
	await get_tree().create_timer($DamageTime.wait_time).timeout
	if health > 0:
		position = last_checkpoint.position
	
func on_checkpoint(_checkpoint: Area2D):
	last_checkpoint = _checkpoint
	
func get_input_direction(): 
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		
	if direction != 0:	
		flip_player(direction)
		
	if is_on_floor():
		dashed = false
		
	return direction
	
func get_input_vector():
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if direction.x != 0:
		flip_player(direction.x)

	return direction.normalized()
	
func add_ghost():
	var ghost = ghost.instantiate()
	ghost.set_property(position, $AnimatedSprite2D.scale, facing)
	get_tree().current_scene.add_child(ghost)
	
func is_on_wall_check():
	return $WallChecker.is_colliding() and !is_on_floor()
	
func is_on_wall_head():
	return $WallCheckerHead.is_colliding()
	
func is_touching_ceiling():
	return $CeilingChecker.is_colliding()
	
func is_touching_ceiling_long():
	return $CeilingCheckerLong.is_colliding()
	
func flip_player(direction):
	$AnimatedSprite2D.set_flip_h(direction != 1)
	$AttackArea.scale.x = direction
	$InteractionArea.scale.x = direction
	$AirAttackArea.scale.x = direction
	$WallChecker.rotation_degrees = 90 * -direction
	$WallCheckerHead.rotation_degrees = 90 * -direction
	facing = direction
	
func handle_jump(_delta):
	if Input.is_action_pressed("jump") and !jumped:
		jump_timer += _delta
		if jump_timer > JUMP_TIMER_MAX:
			jumped = true
			return
		velocity.y = -JUMP_IMPULSE
		
	if Input.is_action_just_released("jump"):
		jumped = true
		
func handle_horizontal_movement(coefficient = 1):
	if get_input_direction() == 0:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
	else:
		velocity.x += SPEED_IMPULSE * facing
		if abs(velocity.x) >= abs(SPEED * coefficient):
			velocity.x = SPEED * facing
			
func damage_conditions():
	return just_hitted and ($InvicibilityFrames.time_left > 0 or $RollInvFrames.time_left > 0)
		
func eat_conditions():
	return (
		Input.is_action_just_pressed("eat") and 
		is_on_floor() and 
		can_eat and 
		health != max_health
	)
	
func dash_conditions():
	return (
		InputBuffer.is_action_press_buffered("dash") and
		dash_count != max_dash and 
		not dash_timeout and 
		not dashed and 
		can_dash
	)
		  
func freeze_conditions():
	return freezed

func get_damage(direction):
	if $InvicibilityFrames.time_left > 0 or $RollInvFrames.time_left > 0:
		return
	damage_from = direction
	just_hitted = true
	
func gain_health(qty):
	if health == max_health: return
	health += qty
	emit_signal("health_changed", health)
	
func disable_atk_collision(value = "both"):
	match(value):
		"both":
			$AttackArea/CollisionShape2D.disabled = true
			$AirAttackArea/CollisionShape2D.disabled = true
		"floor":
			$AttackArea/CollisionShape2D.disabled = true
		"air":
			$AirAttackArea/CollisionShape2D.disabled = true
	
func frame_freeze(time_scale, duration):
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
	
func handle_knockback(amount = 100):
	$KnockbackTime.start()
	velocity.x = amount * (facing * -1)
	
# timers
func _on_AttackComboDelay_timeout():
	combo_count = -1
	
func _on_DamageTime_timeout():
	just_hitted = false
	
func _on_InvicibilityFrames_timeout():
	modulate.a = 1
	
func _on_DeathTime_timeout():
	velocity.x = lerp(velocity.x, 0.0, 0.2)
	
func _on_ghost_time_timeout():
	add_ghost()
	
func _on_dash_delay_timeout():
	dash_timeout = false
	if dash_count > 0 and is_on_floor():
		dash_count -= 1

# areas
func _on_AttackArea_body_entered(body):
	if body.has_method("handle_hit") and !$AttackArea/CollisionShape2D.disabled:
		handle_knockback()
		body.handle_hit(facing)
		screenShake.start()
		
func _on_AirAttackArea_body_entered(body):
	if body.has_method("handle_hit") and !$AirAttackArea/CollisionShape2D.disabled:
		handle_knockback()
		body.handle_hit(facing)
		screenShake.start()
		
func _on_FeetArea_body_entered(body):
	is_on_floor()
	if body.has_method("get_eaten"):
		can_eat = true
		meat_body.append(body)

func _on_FeetArea_body_exited(body):
	if body.has_method("get_eaten"):
		meat_body.erase(body)
		if meat_body.is_empty(): can_eat = false

func _on_interaction_area_body_entered(body):
	if body is Interactable:
		can_interact_with = true
		body.do_highlight()
		interactable_obj = body

func _on_interaction_area_body_exited(body):
	if body is Interactable:
		can_interact_with = false
		body.undo_highlight()
		interactable_obj = null
