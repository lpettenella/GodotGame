extends PlayerState
class_name PlayerDeath

var death_timer : Timer

func enter(_msg := {}):
	animated_sprite.play("death")
	player.velocity.x = 100 * (player.facing * -1)
	player.velocity.y = 0
	
	death_timer = player.get_node("DeathTime")
	death_timer.start()
	
	player.frame_freeze(0.1, 0.6)
	player.disable_atk_collision()
	
func physics_update(_delta: float):
	if not animated_sprite.is_playing():
		get_tree().reload_current_scene()

	player.velocity.y += player.GRAVITY
	
	player.move_and_slide()

