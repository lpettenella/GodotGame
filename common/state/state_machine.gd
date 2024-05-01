class_name StateMachine
extends Node

@export var initial_state : State
@export var movement : MovementComponent

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_change_transition)
			child.animated_sprite = get_parent().get_node("AnimatedSprite2D")
			if movement:
				child.movement = movement
	
	if initial_state: 
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_change_transition(state, new_state_name, msg: Dictionary = {}):
	var new_state = states.get(new_state_name.to_lower())
	
	if msg.has("conditioned") and current_state in new_state.not_if_states:
		print("the new state ", new_state_name, " can't be accessed from ", state.name)
		return
	
	if !new_state: 
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter(msg)
	current_state = new_state
