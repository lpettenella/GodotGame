extends Node2D

var opening = false
var closing = false

var enter_enabled = true
var exit_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if closing: $BottomCS.disabled = false

func _on_animated_sprite_2d_animation_finished():
	match($AnimatedSprite2D.animation):
		"phase1": 
			if opening: $AnimatedSprite2D.play("phase2")
			if closing: closing = false
		"phase2": 
			if opening: 
				opening = false
				$BottomCS.disabled = true
			if closing: 
				$AnimatedSprite2D.play_backwards("phase1")
				
func open(): 
	$AnimatedSprite2D.play("phase1")
	opening = true
	enter_enabled = false
	
func close():
	$AnimatedSprite2D.play_backwards("phase2")
	closing = true
	exit_enabled = false
				

func _on_enter_body_entered(body):
	if body.name == "Player" and enter_enabled:
		open()
		
func _on_exit_body_exited(body):
	if body.name == "Player" and exit_enabled:
		close()
