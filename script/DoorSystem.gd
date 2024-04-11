extends Node

var connected_items = 0
var triggered = false
var door : Door

# Called when the node enters the scene tree for the first time.
func _ready():
	door = $Door
	if $PanelControl != null: 
		$PanelControl.door = door
	for child in $Items.get_children():
		if child is ToggleItem and child.is_active:
			child.Deactive.connect(on_item_deactivated) 
			connected_items += 1

func _process(delta):
	pass
		
func on_item_deactivated(body):
	print("deactivated ", body)
	connected_items -= 1
	if $PanelControl != null:
		$PanelControl.active_a_button(connected_items)
	elif connected_items == 0:
		door.open()
