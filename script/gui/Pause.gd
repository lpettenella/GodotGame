extends Control

var all_items = []
var inventory = []
var inv_opened = false
var index = 0
var n_present = 0

func _ready():
	for child in get_children():
		all_items.append({"data": child, "present": false})
		child.Add.connect(on_inventory_item_add)

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().paused = false
		inv_opened = false
		for child in get_children():
			child.visible = false
			
	if Input.is_action_just_pressed("inventory") and not inv_opened:
		if not inventory.is_empty():
			get_tree().paused = true
			inventory[0].visible = true
			inv_opened = true
			
	if Input.is_action_just_pressed("right") and inv_opened:
		if inventory.size() == 1: return 
		if index + 1 < inventory.size():
			index += 1
		else: 
			index = 0
			
		for child in get_children():
			child.visible = false
		
		inventory[index].visible = true
		
func on_inventory_item_add(_item):
	if _item not in inventory:
		inventory.append(_item)
