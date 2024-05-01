class_name EnemyAttack
extends EnemyState

var attack_component

func enter(_msg := {}):
	attack_component = enemy.get_node("AttackComponent")
	animated_sprite.play("attack")
	
func physics_update(_delta: float):
	attack_component.handle_attack()
		
	if not animated_sprite.is_playing():
		if enemy.target:
			Transitioned.emit(self, "Chase")
		else:
			Transitioned.emit(self, "Wander")
		return
		
	enemy.velocity.x = 0
	
func exit():
	attack_component.stop_attack()
