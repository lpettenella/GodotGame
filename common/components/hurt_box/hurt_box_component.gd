class_name HurtBoxComponent
extends Area2D

@export var health_box_component : HealthComponent

func damage(_amount: int, _direction: int):
	if health_box_component:
		health_box_component.damage(_amount, _direction)
