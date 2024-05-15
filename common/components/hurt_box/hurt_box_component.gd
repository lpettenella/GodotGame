class_name HurtBoxComponent
extends Area2D

@export var health_box_component : HealthComponent
@export var invincibility_time = 0.1

var inv_timer = 0.0
var timer_started = false

func _process(delta):
	if timer_started:
		if inv_timer < invincibility_time:
			inv_timer += delta
		else:
			timer_started = false
			inv_timer = 0.0

func damage(_amount: int, _direction: int):
	if health_box_component and not timer_started:
		timer_started = true
		health_box_component.damage(_amount, _direction)
