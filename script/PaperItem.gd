extends Interactable

@export var canvas_item : Control

var state = "idle"

func _process(delta): 
	if $AnimatedSprite2D.animation != state:
		$AnimatedSprite2D.play(state)

func do_interact():
	canvas_item.visible = !canvas_item.visible
	canvas_item.add_to_inventory()
	get_tree().paused = true
	
func do_highlight():
	state = "highlight"

func undo_highlight():
	state = "idle"
