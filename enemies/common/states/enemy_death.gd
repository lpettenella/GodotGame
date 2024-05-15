class_name EnemyDeath
extends EnemyState

@export var drop : PackedScene
var drop_instance

func enter(_msg := {}):
	animated_sprite.play("death")
	enemy.get_node("Hit").play()
	if drop:
		drop_instance = drop.instantiate()
		drop_instance.global_position = enemy.global_position
		get_tree().current_scene.add_child(drop_instance)
	
func physics_update(_delta: float):
	if not animated_sprite.is_playing():
		if drop_instance:
			drop_instance.modulate.a = 1
		enemy.queue_free()
		
	enemy.velocity = Vector2()
	
func exit():
	pass
