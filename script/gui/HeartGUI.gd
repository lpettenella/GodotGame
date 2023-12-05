extends Panel

@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_heart(whole): 
	if whole: sprite.frame = 0
	else: sprite.frame = 1
