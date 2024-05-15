class_name EnemyHit
extends EnemyState

@export var hit_time = 0.15
@export var particles : PackedScene

var my_random_number
var hit_timer = 0.0
var direction

func enter(_msg := {}):
	if _msg.has("direction"):
		direction = _msg.direction
		
	animated_sprite.play("hit")
	enemy.get_node("Hit").play()
	
	if particles:
		emit_particles()
	
	my_random_number = randi() % 4 + 1
	hit_timer = 0.0
	
func physics_update(_delta: float):
	if hit_timer >= hit_time:
		Transitioned.emit(self, "Chase", {from_hit = true})
		return
		
	hit_timer += _delta
	enemy.velocity.x = enemy.KNOCKBACK_SPEED * my_random_number * direction
	enemy.velocity.y = -enemy.GRAVITY * 3
	
func exit():
	pass
	
func emit_particles(): 
	var particles_instance = particles.instantiate()
	particles_instance.global_position = enemy.global_position
	particles_instance.emitting = true
	get_tree().current_scene.add_child(particles_instance)
