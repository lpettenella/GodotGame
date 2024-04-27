extends Node

@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if initial_state: 
		initial_state.enter()
		current_state = initial_state
		
#func _unhandled_input(event):
	#current_state.handle_input(event)

func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state, new_state_name, msg: Dictionary = {}):
	#print(state, " to ", new_state_name)
	var new_state = states.get(new_state_name.to_lower())
	if !new_state: 
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter(msg)
	current_state = new_state