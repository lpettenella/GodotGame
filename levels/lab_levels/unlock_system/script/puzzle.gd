extends Node2D

@export var max_tries = -1
@export var configurations = [[0,1,3], [0,1,2], [1,2,3], [2,3,0]]

var index = 0
var items = []
var solved = false

var n_pressed = 0

func _ready():
	for child in get_children():
		if not child is Interactable: continue
		
		child.Interact.connect(on_item_interacted)

		items.append({
			"data": child, 
			"conf": configurations[index], 
			"init_active": child.active
		})
		
		index += 1

func _process(delta):
	pass
	
func on_pressing():
	#n_pressed += 1
	#if n_pressed > max_tries and max_tries != -1:
		#reset()
		#return
	
	# if all item are deactive the door open
	for item in items:
		if item.data.active:
			return
	solved = true
	$Door.open()
		
func reset():
	var index = 0
	for item in items:
		item.data.active = item.init_active
		index += 1
	n_pressed = 0
	print("puzzle resetted")
	
func on_item_interacted(_item):
	if solved: return
	for item in items:
		if item.data == _item:
			do_active_deactive_items(item.conf)
			on_pressing()
	
func do_active_deactive_items(index: Array):
	for i in index:
		items[i].data.do_active_deactive()
