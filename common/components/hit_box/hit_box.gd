extends Area2D

@export var movement_component : MovementComponent

signal stun

var timer = null

#func _on_body_entered(body):
	#if body.has_method("get_damage"):
		#body.get_damage(movement_component.facing)
		
func _process(delta):
	if timer:
		print(timer.time_left)

func _on_area_entered(area):
	if area.name == "AttackArea":
		get_parent().get_node("ParryParticles").emitting = true
		timer = area.get_parent().get_node("InvicibilityFrames")
		timer.start()
		stun.emit()
	elif area.name == "HurtBox" and area.get_parent().has_method("get_damage"):
		area.get_parent().get_damage(movement_component.facing)
