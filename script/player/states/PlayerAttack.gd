extends PlayerState
class_name PlayerAttack

var on_air = false
var actual_combo

func enter(_msg := {}):
	actual_combo = player.melee_map[player.combo_count]
	animated_sprite.play(actual_combo)
	player.attacked = false
	player.queued_attack = false
	if player.get_input_direction() != 0:
		player.velocity.x = 500 * player.get_input_direction()
	
func physics_update(_delta: float):
	if actual_combo == "attack1" and animated_sprite.frame == 3:
		attack_area.disabled = false
	elif actual_combo != "attack1":
		attack_area.disabled = false
	
	if player.attacked:
		if player.queued_attack:
			Transitioned.emit(self, actual_combo)
		else:
			Transitioned.emit(self, "idle")
		return
	
	if Input.is_action_just_pressed("attack"):
		player.queued_attack = true
		
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.1)
	player.velocity.y += player.GRAVITY
	player.move_and_slide()

func exit():
	attack_area.disabled = true
	player.combo_count = (player.combo_count + 1) % 3

