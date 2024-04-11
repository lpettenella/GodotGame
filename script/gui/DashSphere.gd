extends Node

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player.freezed = true
		await wait(1)
		$AnimatedSprite2D.play("action")
		
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "action":
		player.freezed = false
		player.can_dash = true
		player.max_dash += 1
		$Area2D/CollisionShape2D.disabled = true
