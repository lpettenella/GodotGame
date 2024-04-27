extends PlayerState
class_name PlayerEat

func enter(_msg := {}):
	animated_sprite.play("eat")
	player.actual_meat = player.meat_body.back()
	
func physics_update(_delta: float):
	player.velocity = player.position.direction_to(player.actual_meat.position) * player.SPEED

	if not animated_sprite.is_playing():
		handle_post_eat()
		Transitioned.emit(self, "idle")
		return
		
	player.move_and_slide()
	
func handle_post_eat():
	var meat_to_eat = player.meat_body.pop_at(-1)
	if meat_to_eat != null:
		meat_to_eat.get_eaten()
		player.gain_health(1)
