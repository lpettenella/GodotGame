extends Node2D

var player = null
var triggered = false

func _ready():
	if $CanvasLayer/Control/TextureRect.texture is AnimatedTexture:
		$CanvasLayer/Control/TextureRect.texture.pause = true

func _process(delta):
	pass
	#if player != null:
		#$CanvasLayer/Control.visible = true

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		if $CanvasLayer/Control/TextureRect.texture is AnimatedTexture:
			if $CanvasLayer/Control/TextureRect.texture.pause:
				$CanvasLayer/Control/TextureRect.texture.pause = false
				$CanvasLayer/Control/TextureRect.texture.current_frame = 0
		$CanvasLayer/Control.visible = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
		$CanvasLayer/Control.visible = false
