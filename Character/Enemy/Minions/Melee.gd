extends "res://Character/Enemy/enemy.gd"

var dirVec = Vector2()
export var AttackRange: int

signal HitPlayer(Damage)

func _ready():
	$Detection/CollisionShape2D.get_shape().set_radius(DetectionRadius)
	$"Attack Range/CollisionShape2D".get_shape().set_radius(AttackRange)
	dirVec.x = rng.randf_range(-100.0, 100.0)
	dirVec.y = rng.randf_range(-100.0, 100.0)
	dirVec = dirVec.normalized()
	currentState = State.STATE_CHASE
	$"Attack Area/CollisionShape2D".disabled = true
	
	connect("HitPlayer", target, "on_Hit")

func _physics_process(delta):
	#print (dirVec)
	match currentState:
		State.STATE_CHASE:
			chase(delta)
			if dirVec.x >= 0:
				match currentState:
					State.STATE_CHASE:
						
						# Moving to Right
						if $AnimationPlayer.current_animation != "Attack":
							$AnimationPlayer.play("Move_Right")
						
			
			elif dirVec.x < 0:
				
				match currentState:
					State.STATE_CHASE:
						
						# Moving to Left
						if $AnimationPlayer.current_animation != "Attack":
							$AnimationPlayer.play("Move_Left")

			
		State.STATE_PATROL:
			patrol(delta)
			
		State.STATE_ATTACK:
			$"Attack Area".rotation = dirVec.angle() + PI
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")

func chase(delta):
	if $AnimationPlayer.current_animation != "Attack":
		# Get player position
		var targetPos = target.position
		
		# Get direction vector 
		dirVec = targetPos - position
		dirVec = dirVec.normalized()
		
		move_and_slide(dirVec * Speed)
	
func patrol(delta):
	# Move towards
	move_and_slide(dirVec * Speed)

	
func _on_Detection_body_entered(body):
	# Turn on Chase Mode
	if body.is_in_group("Player"):
		currentState = State.STATE_CHASE
		$"Patrol Timer".stop()

func _on_Patrol_Timer_timeout():
	dirVec.x = rng.randf_range(-100.0, 100.0)
	dirVec.y = rng.randf_range(-100.0, 100.0)
	dirVec = dirVec.normalized()
	$"Patrol Timer".start()

func _on_Attack_Range_body_entered(body):
	if body.name == "Player":
		currentState = State.STATE_ATTACK


func _on_Attack_Area_body_entered(body):
	if body.name == "Player":
		emit_signal("HitPlayer", Damage)


func _on_Attack_Range_body_exited(body):
	if currentState != State.STATE_DEAD or currentState != State.STATE_DROPLOOT:
		currentState = State.STATE_CHASE
