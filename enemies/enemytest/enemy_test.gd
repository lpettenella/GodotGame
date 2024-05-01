class_name EnemyTest
extends CharacterBody2D

const SPEED = 50.0
const GRAVITY = 30
const FALL_LIMIT = 300
const KNOCKBACK_SPEED = 20.0

@onready var sm : StateMachine = $StateMachine
var target = null

func _ready():
	$HealthComponent.damaged.connect(on_damage)
	$HealthComponent.dead.connect(on_death)
	$ChaseComponent.player_entered.connect(on_player_entered_chase_range)
	$ChaseComponent.player_exited.connect(on_player_exited_chase_range)
	if $AttackComponent:
		$AttackComponent.attack.connect(on_attack)

func _physics_process(delta):
	if GRAVITY >= FALL_LIMIT:
		velocity.y = FALL_LIMIT
	else:
		velocity.y += GRAVITY
		
	move_and_slide()
	
func on_damage(facing):
	change_state("Hit", {direction = facing, conditioned = true})

func on_death():
	change_state("Death", {conditioned = true})
	
func on_player_entered_chase_range(player):
	target = player
	change_state("Chase", {conditioned = true})
	
func on_player_exited_chase_range(player):
	target = null
	change_state("Wander", {conditioned = true})
	
func on_attack():
	change_state("Attack", {conditioned = true})
		
func change_state(new_state, msg = {}):
	if common_conditions():
		sm.on_change_transition(sm.current_state, new_state, msg)
	
func common_conditions():
	return not sm.current_state is EnemyDeath
