extends StaticBody2D
class_name Door

@export var is_open = false

func _ready():
	$AnimatedSprite2D.play("open" if is_open else "closed")

func _process(delta):
	$CollisionShape2D.disabled = is_open

func open():
	is_open = true 
	$AnimatedSprite2D.play("open")
	$Open.play()
	
func close(): 
	is_open = false
	$AnimatedSprite2D.play("closed")
