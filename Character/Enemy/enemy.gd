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
	setStats()
	$Base/HealthBar.max_value = Health
	$Base/HealthBar.value = Health
	$Base/HealthBar.hide()
	MAIN = $".".get_parent().get_parent().get_parent()
	
	connect("DropLoot", MAIN, "dropLoot", [], CONNECT_ONESHOT)
	connect("GiveEXP", target, "addEXP", [], CONNECT_ONESHOT)
	
	rng.randomize()
	
func setStats():
	# Function takes a look at player current level and tweak enemy stats accordingly
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	var playerLevel = playerScene.level
	Health = playerLevel * 5 + Health
	Speed = playerLevel * 5 + Speed
	Damage = playerLevel * 3 +  Damage
	EXP = int (pow(playerLevel, 0.5)* 100)
	
	
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
	var playerLvl = get_tree().get_nodes_in_group("Player")[0].level
	var variance = rng.randi_range(-ValueRange, ValueRange)
	var totalGold = (BaseValue + variance)*playerLvl*0.8
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
	
	
func init():
	pass

