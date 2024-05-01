class_name HealthComponent
extends Node2D

signal dead
signal damaged

@export var MAX_HEALTH = 10.0
@onready var health = MAX_HEALTH
	
func damage(amount: int, facing: int):
	health -= amount
	if health == 0:
		dead.emit()
	else:
		damaged.emit(facing)
