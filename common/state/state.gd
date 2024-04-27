extends Node
class_name State

signal Transitioned

func enter(_msg := {}):
	pass
	
func exit():
	pass
	
func handle_input(_event: InputEvent):
	pass
	
func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass
