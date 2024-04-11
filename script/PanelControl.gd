extends StaticBody2D

@export var password = [1, 2, 3]

var inserted_pwd : Array = []
var buttons : Array = []
var door : Door

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for child in $Buttons.get_children():
		if child is ButtonPanel:
			child.Pressed.connect(on_pressed)
			buttons.append(child)
			index += 1
	
func active_a_button(index):
	buttons[index].do_active()

func _process(delta):
	pass
	
func on_pressed(button_number: int):
	inserted_pwd.append(button_number)
	check_pwd()

func check_pwd():
	if inserted_pwd.size() < password.size():
		print(inserted_pwd)
		return
	if inserted_pwd == password:
		print("correct password!")
		door.open()
	else:
		print("wrong password")
		inserted_pwd = []
		for button in buttons:
			button.undo_press_button()
