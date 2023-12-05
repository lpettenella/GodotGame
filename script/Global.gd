extends Node2D

@onready var health_bar = $GUI/PlayerBar/HealthBar
@onready var player = $Player

func _ready():
	Engine.time_scale = 1.0
	health_bar.set_max_hearts(player.max_health)
	health_bar.update_hearts(player.health)
	player.connect("health_changed",Callable(health_bar,"update_hearts"))
