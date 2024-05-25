class_name AttackComponent
extends Area2D

signal attack

@export var attack_delay_time = 0.0
@export var from_frame = 0
@export var to_frame = 1
@export var hit_box : CollisionShape2D
@export var animated_sprite : AnimatedSprite2D

var attack_timer = 0.0
var is_delay_time = false
var in_trigger_area = false
var is_attacking = false
	
func _physics_process(delta):
	if is_delay_time:
		attack_timer += delta
			
	if attack_timer >= attack_delay_time:
		attack_timer = 0.0
		is_delay_time = false
		
	if not is_attacking and in_trigger_area and not is_delay_time:
		attack.emit()
		
func handle_attack():
	match(animated_sprite.frame):
		from_frame:
			active_hit_box()
		to_frame:
			disable_hit_box()
		
func start_attack():
	is_attacking = true
		
func stop_attack():
	is_attacking = false
	is_delay_time = true
	disable_hit_box()

func disable_hit_box():
	hit_box.set_deferred("disabled", true)
	
func active_hit_box():
	hit_box.disabled = false

func _on_body_entered(body):
	if body.name == "Player":
		in_trigger_area = true

func _on_body_exited(body):
	if body.name == "Player":
		in_trigger_area = false
