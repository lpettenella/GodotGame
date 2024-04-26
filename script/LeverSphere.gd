extends Interactable
class_name LeverSphere

@export var active = false
var state

func _ready():
	pass
	
func _process(delta):
	if state != "highlight":
		state = "active" if active else "deactive"
	$PointLight2D.enabled = active
	if $AnimatedSprite2D.animation != state:
		$AnimatedSprite2D.play(state)
	
func do_interact():
	Interact.emit(self)
	
func do_active_deactive():
	active = not active
	
func do_highlight():
	state = "highlight"

func undo_highlight():
	state = "active" if active else "deactive"
