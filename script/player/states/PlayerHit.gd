extends PlayerState
class_name PlayerHit

func enter(_msg := {}):
	player.get_node("DamageTime").start()
	player.get_node("KnockbackTime").start()
	player.get_node("InvicibilityFrames").start()
	animated_sprite.play("damage")
	player.health -= 1

	#freeze
	player.frame_freeze(0.1, 0.3)
	
	#health bar
	player.emit_signal("health_changed", player.health)
	#player.velocity.x = 0
	
	#knockback
	player.velocity.x = 300 * player.damage_from
	
	#change colour
	player.modulate.a = 0.5

	player.disable_atk_collision()
	
func physics_update(_delta: float):
	if player.health <= 0:
		Transitioned.emit(self, "death"	)
		return
	if player.get_node("DamageTime").time_left <= 0: 
		Transitioned.emit(self, "idle")
		return
			
	player.velocity.y = 0
	
	player.move_and_slide()


