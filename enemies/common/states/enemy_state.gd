class_name EnemyState
extends State

var enemy : EnemyTest
var animated_sprite : AnimatedSprite2D
var movement : EnemyMovement

func _ready():
	await owner._ready
	enemy = owner as EnemyTest
