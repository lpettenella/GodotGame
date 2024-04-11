extends Interactable

@export var control : Control
var state = "idle"

func _process(delta): 
	if Input.is_action_pressed("exit"):
		control.visible = false
	if $AnimatedSprite2D.animation != state:
		$AnimatedSprite2D.play(state)

func do_interact():
	control.visible = !control.visible
	
func do_highlight():
	state = "highlight"

func undo_highlight():
	state = "idle"
