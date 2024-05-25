extends Area2D

var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("main")

func _physics_process(delta):
	$AnimatedSprite2D.visible = false if target == null else true

func _on_body_entered(body):
	target = body

func _on_body_exited(body):
	target = null
