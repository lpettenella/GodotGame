extends State
class_name PlayerState

var player: Player
var animated_sprite : AnimatedSprite2D
var attack_area : CollisionShape2D
var air_attack_area : CollisionShape2D

func _ready():
	await owner._ready
	player = owner as Player
	attack_area = player.get_node("AttackArea/CollisionShape2D")
	air_attack_area = player.get_node("AirAttackArea/CollisionShape2D")
	animated_sprite = player.get_node("AnimatedSprite2D")
	assert(player != null)
	
func _physics_process(_delta: float):
	if player.freeze_conditions():
		Transitioned.emit(self, "freeze")
