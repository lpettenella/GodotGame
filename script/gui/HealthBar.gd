extends HBoxContainer

@onready var HeartGUIClass = preload("res://scenes/gui/HeartGUI.tscn")
@onready var max_hearts = 1

func _ready():
	pass
	
func _process(delta):
	pass
	
func set_max_hearts(value):
	max_hearts = value
	for i in range(value): 
		var heart = HeartGUIClass.instantiate()
		add_child(heart)
		
func update_hearts(value):
	var hearts = get_children()
	
	for i in range(value):
#		var idx = max_hearts - 1 - i	
		hearts[i].update_heart(true)
	
	for i in range(value, hearts.size()):
#		var idx = max_hearts - 1 - i
		hearts[i].update_heart(false)
		

