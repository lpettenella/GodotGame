extends PlayerState
class_name PlayerAttackAir

var attack_air_area : CollisionShape2D
var on_air = false

func enter(_msg := {}):
	player.get_node("AnimatedSprite2D").play("jumpattack")
	player.attacked = false
	
func physics_update(_delta: float):
	air_attack_area.disabled = false
	
	if player.attacked:
		if not player.is_on_floor():
			Transitioned.emit(self, "air")
		else:
			Transitioned.emit(self, "idle")
		return
	
	#if Input.is_action_just_pressed("attack"):
		#player.queued_attack = true
	
	player.handle_jump(_delta)
	
	player.velocity.x = lerp(player.velocity.x, 0.0, 0.1)
	player.velocity.y += player.GRAVITY
	player.move_and_slide()
	
func exit():
	air_attack_area.disabled = true
