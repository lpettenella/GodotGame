extends Interactable
class_name ButtonPanel

signal Pressed

@export var button_number = 0
@export var active = false

var state = "deactive"

func _ready():
	state = "active" if active else "deactive"

func _process(delta):
	if state != $AnimatedSprite2D.animation:
		$AnimatedSprite2D.play(state)
		
func do_active():
	active = true
	state = "active"
	#$Area2D/CollisionShape2D.disabled = false
	#$PointLight2D.enabled = true
	
func do_deactive():
	active = false
	state = "deactive"
	$PointLight2D.enabled = false
		
func do_interact():
	print("interacted")
	if not active: return
	Pressed.emit(button_number)
	flash_btn()
	
func undo_press_button():
	if not active: return
	flash_btn()
	
func do_highlight():
	if not active: return
	state = "highlight"
	
func undo_highlight():
	state = "active" if active else "deactive"
	
func flash_btn():
	$PointLight2D.enabled = true
	await wait(0.15)
	$PointLight2D.enabled = false
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
