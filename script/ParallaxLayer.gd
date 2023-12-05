extends ParallaxLayer

var offset_x = 100

func _physics_process(delta):
	set_motion_offset(Vector2(offset_x,0))
	offset_x += 1
	pass

func _ready():
	pass
