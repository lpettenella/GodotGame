extends ToggleItem
class_name Capsule

@export var mob : PackedScene

var hits = ["hit1", "hit2", "hit3"]
var index_hit = -1
var state = "idle"
var mob_instance = null

func _ready():
	$AnimatedSprite2D.play(state)

func _process(delta):
	if state != $AnimatedSprite2D.animation:
		$AnimatedSprite2D.play(state)
		
	if state == "brake":
		$CollisionShape2D.disabled = true
		
	if $AnimatedSprite2D.animation == "brake" and $AnimatedSprite2D.frame == 6 and mob_instance == null:
		mob_instance = mob.instantiate()
		mob_instance.position.x = global_position.x
		mob_instance.position.y = global_position.y
		get_tree().current_scene.add_child(mob_instance)
	
func handle_hit(from): 
	if state == "brake":
		return
	index_hit += 1
	if index_hit == 2:
		state = "brake"
		is_active = false
		Deactive.emit(self)
		$PointLight2D.enabled = false
	else:
		state = hits[index_hit]

