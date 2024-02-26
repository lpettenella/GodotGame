extends PlayerState
class_name PlayerAttackOld

var attack_area : CollisionShape2D 
var attack_air_area : CollisionShape2D
var on_air = false

func enter(_msg := {}):
	player.attacked = false
	attack_area = player.get_node("AttackArea/CollisionShape2D")
	attack_air_area = player.get_node("AirAttackArea/CollisionShape2D")
	if _msg.has("on_air"):
		on_air = true
		player.get_node("AnimatedSprite2D").play("jumpattack")
	else:
		player.combo_count = (player.combo_count + 1) % 3
		player.get_node("AnimatedSprite2D").play(player.melee_map[player.combo_count])
	
func physics_update(_delta: float):
	if not player.is_on_floor():
		player.handle_jump(_delta)
		if player.attacked: 
			Transitioned.emit(self, "air")
			return
		attack_air_area.disabled = false
	else:
		if player.attacked:
			Transitioned.emit(self, "idle")
			return
		attack_area.disabled = false
		#player.combo_count = (player.combo_count + 1) % 3
	
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.3)
	player.velocity.y += player.GRAVITY
	player.move_and_slide()


