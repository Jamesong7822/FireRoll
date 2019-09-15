extends "res://Character/Character.gd"

const KNOCKBACKSPEED = 200

export var Damage: int
export var DamageRange: int
export var CriticalChance: int
export var CriticalMultiplier: float
export var DetectionRadius: int
export var DropRate: int
export var BaseValue: int
export var ValueRange: int

var Level: int

var EXP

enum State {STATE_PATROL, STATE_CHASE, STATE_ATTACK, STATE_KNOCKBACK, STATE_DROPLOOT, STATE_DEAD}

var currentState
var knockback
var knockbackVector = Vector2()
var beforeKnockBackPos = Vector2()

onready var target = get_tree().get_nodes_in_group("Player")[0]
onready var GOLD = preload("res://Items/Consumables/Coins.tscn")
var MAIN

var rng = RandomNumberGenerator.new()

signal DropLoot(gold, pos)
signal GiveEXP(EXP)

func _ready():
	add_to_group("Enemies")
	#add_to_group("Saving")
	$Base/HealthBar.max_value = Health
	$Base/HealthBar.value = Health
	$Base/HealthBar.hide()
	MAIN = $".".get_parent().get_parent().get_parent()

	connect("DropLoot", MAIN, "dropLoot", [], CONNECT_ONESHOT)
	connect("GiveEXP", target, "addEXP", [], CONNECT_ONESHOT)
	
	rng.randomize()
	
func setStats(hpGrowth, speedGrowth, maxSpeed, dmgGrowth):
	# Function sets the stats of the enemy based on the enemy level
	
	Health += Level * hpGrowth
	
	Speed += Level * speedGrowth
	#print ("Caculated Speed: ", Speed, " Max Speed: ", maxSpeed)
	Speed = clamp(Speed, 0, maxSpeed)
	
	Damage += Level * dmgGrowth
	
	EXP = int (0.3 * Health + 0.3 * Speed + 2 * Damage)
	BaseValue += Level
	
	
func _physics_process(delta):
	checkDeath()
		
	match currentState:
		State.STATE_KNOCKBACK:
			
			# Get target pos
			var targetPos = target.position 
			# Get knockback dir vector
			knockbackVector = (targetPos - position).normalized()

			position -= knockbackVector * KNOCKBACKSPEED * delta
			if (position - beforeKnockBackPos).length() > knockback:
				currentState = State.STATE_CHASE
				
		State.STATE_DEAD:
			# Death
			#$AnimationPlayer.clear_queue()
			$AnimationPlayer.current_animation = "Death"
			yield($AnimationPlayer, "animation_finished")
			
			queue_free()
			
		State.STATE_DROPLOOT:
			# Drop loot
			dropLoot()
			currentState = State.STATE_DEAD
				
func checkDeath():
	if Health <= 0:
		if currentState != State.STATE_DEAD:
			currentState = State.STATE_DROPLOOT
		
		
func dropLoot():
	#print ("DROP LOOT")
	var variance = rng.randi_range(-ValueRange, ValueRange)
	var totalGold = (BaseValue + variance)
	emit_signal("DropLoot", totalGold, position)
	emit_signal("GiveEXP", EXP)
	
		
func hit(damage):
	beforeKnockBackPos = position
	currentState = State.STATE_KNOCKBACK
	#$"Knockback Timer".start()
	Health -= damage
	$AnimationPlayer.play("Take_Damage")
	$Base/HealthBar.show()
	$Base/HealthBar.value -= damage
	
	
func generateSaveData():
	print ("Generating Enemy Save Data")
	var saveDict = {}
	saveDict = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"Name": Name,
		"Health": Health,
		"Speed": Speed,
		"Damage": Damage,
		"pos_x": position.x,
		"pos_y": position.y
		}
		
	return saveDict
	
	


