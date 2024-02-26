extends CharacterBody2D
class_name Player

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

const melee_map = ["attack1", "attack2", "attack3"]
var combo_count = -1
var queued_attack = false

@onready var health = max_health
signal health_changed

var attacked = false
var jumped = false
var jump_timer = 0.0
var facing = true
	
func _physics_process(delta):
	if velocity.y > FALL_LIMIT:
		velocity.y = FALL_LIMIT

func _ready():
	pass
	
func get_input_direction(): 
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		
	if direction != 0:	
		flip_player(direction)
	
	return direction
	
func is_on_wall_check():
	return $WallChecker.is_colliding() and !is_on_floor()
	
func flip_player(direction):
	$AnimatedSprite2D.set_flip_h(direction != 1)
	$AttackArea.scale.x = direction
	$AirAttackArea.scale.x = direction
	$WallChecker.rotation_degrees = 90 * -direction
	facing = direction
	
func handle_jump(_delta):
	if Input.is_action_pressed("jump") and !jumped:
		jump_timer += _delta
		if jump_timer > JUMP_TIMER_MAX:
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
		
func get_damage(damage):
	pass
	
func _on_animated_sprite_2d_animation_finished():
	match($AnimatedSprite2D.animation):
		"prefall": 
			$AnimatedSprite2D.play("fall")
		"attack1", "attack2", "attack3":
			attacked = true
			$AttackComboDelay.start()
		"jumpattack": 
			attacked = true
		
func _on_AttackComboDelay_timeout():
	combo_count = -1
