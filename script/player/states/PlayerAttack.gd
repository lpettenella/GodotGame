extends PlayerState
class_name PlayerAttack

var on_air = false
var actual_combo
@onready var attack_sound = get_parent().get_node("Attack")

func enter(_msg := {}):
	attack_sound.play()
	actual_combo = player.melee_map[player.combo_count]
	animated_sprite.play(actual_combo)
	player.attacked = false
	player.queued_attack = false
	if player.get_input_direction() != 0:
		player.velocity.x = player.SPEED * player.get_input_direction()
	
func physics_update(_delta: float):
	if player.just_hitted:
		air_attack_area.disabled = true
		Transitioned.emit(self, "hit")
		return
		
	if actual_combo == "attack1" and animated_sprite.frame == 3:
		attack_area.disabled = false
	elif actual_combo != "attack1":
		attack_area.disabled = false
	
	if not animated_sprite.is_playing():
		player.get_node("AttackComboDelay").start()
		if player.queued_attack:
			player.combo_count = (player.combo_count + 1) % 3
			Transitioned.emit(self, actual_combo)
			air_attack_area.disabled = true
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
	#player.combo_count = (player.combo_count + 1) % 3

