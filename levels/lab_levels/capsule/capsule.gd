extends ToggleItem
class_name Capsule

@export var mob : PackedScene

var hits = ["hit1", "hit2", "hit3"]
var index_hit = -1
var state = "idle"
var mob_instance = null

func _ready():
	$HealthComponent.damaged.connect(on_damage)
	$HealthComponent.dead.connect(on_death)
	$AnimatedSprite2D.play(state)

func _physics_process(delta):
	if state != $AnimatedSprite2D.animation:
		$AnimatedSprite2D.play(state)
		
	if state == "breaks":
		$HurtBoxComponent/CollisionShape2D.disabled = true
		
	if $AnimatedSprite2D.animation == "breaks" and $AnimatedSprite2D.frame == 6 and mob_instance == null:
		mob_instance = mob.instantiate()
		mob_instance.can_born = true
		mob_instance.position.x = global_position.x
		mob_instance.position.y = global_position.y - 1
		get_tree().current_scene.add_child(mob_instance)
		
func on_damage(facing):
	$Hit.play()
	index_hit += 1
	state = hits[index_hit]

func on_death():
	$Hit.play()
	state = "breaks"
	is_active = false
	Deactive.emit(false)
	$PointLight2D.enabled = false
