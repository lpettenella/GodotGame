extends StaticBody2D

func init(direction):
	$AnimatedSprite2D.set_flip_h(direction != 1)

func _on_animated_sprite_2d_animation_finished():
	queue_free()
