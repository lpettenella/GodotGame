extends CharacterBody2D

const up = Vector2(0, -1)
const speed = 600
const gravity = 70
const maxfallspeed = 2000
const attacks = ["attack", "attack2", "attack3"]
var motion = Vector2()
var attackPressed = false
var isAttacking = false
var isDashing = false
var dashDelayIsFinished = true
var dashTimeStarted = false
var facing_right = true
var comboTime = false
var combo = 0


func _process(delta):

	motion.y += gravity
	if motion.y > maxfallspeed: 
		motion.y = maxfallspeed

	if facing_right == true:
		$AnimatedSprite2D.set_flip_h(false)
		$AttackArea.scale.x = 1
	else: 
		$AnimatedSprite2D.set_flip_h(true)
		$AttackArea.scale.x = -1

	if (isAttacking or isDashing) and Input.is_action_just_pressed("attack"):
		attackPressed = true

	if Input.is_action_pressed("right") and !isAttacking and !isDashing:
		facing_right = true
		motion.x = speed
		$AnimatedSprite2D.play("run")
	elif Input.is_action_pressed("left") and !isAttacking and !isDashing:
		facing_right = false
		motion.x = -speed
		$AnimatedSprite2D.play("run")
	else:
		if isAttacking:
			motion.x = lerp(motion.x, 0, 0.2)
		else: motion.x = lerp(motion.x, 0, 1)
		if !isAttacking and !isDashing: 
			$AnimatedSprite2D.play("idle")

	if (Input.is_action_just_pressed("attack") or attackPressed) and !isDashing and !isAttacking:
		if comboTime:
			$AnimatedSprite2D.play(attacks[combo])
		else:
			$AnimatedSprite2D.play("attack")
			combo = 0

		if combo == attacks.size() - 1: combo = 0
		else: combo += 1

		$AttackArea/CollisionShape2D.disabled = false
		isAttacking = true
		attackPressed = false

	if Input.is_action_just_pressed("dash") and !isAttacking and dashDelayIsFinished:
		$AnimatedSprite2D.play("dash")
		isDashing = true
		dashDelayIsFinished = false
		dashTimeStarted = true
		$DashDelay.start()
		$DashTime.start()

	if isDashing:
		if facing_right:
			motion.x = speed * 3
		else: motion.x = speed * -3

	set_velocity(motion)
	set_up_direction(up * delta)
	move_and_slide()
	motion = velocity

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite2D.animation in attacks:
		isAttacking = false
	if $AnimatedSprite2D.animation == "dash":
		isDashing = false
	if $AnimatedSprite2D.animation == "attack" || $AnimatedSprite2D.animation == "attack2":
		$AttackComboDelay.start()
		comboTime = true

func _on_DashDelay_timeout():
	dashDelayIsFinished = true

func _on_DashTime_timeout():
	dashTimeStarted = false

func _on_AttackComboDelay_timeout():
	comboTime = false

func _on_AttackArea_body_entered(body):	if body.has_method("handle_hit"):
		body.handle_hit()

func _on_AnimatedSprite_frame_changed():
	$AttackArea/CollisionShape2D.disabled = true
