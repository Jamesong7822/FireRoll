extends "res://Character/Enemy/Minions/Melee.gd"

var HEALTHGROWTHRATE = 30
var SPEEDGROWTHRATE = 5
var MAXSPEED = 250
var DAMAGEGROWTHRATE = 2


func _ready():
	pass


func _physics_process(delta):
#	match currentState:
#		State.STATE_CHASE:
#			print ("CHASE")
#		State.STATE_PATROL:
#			print ("Patrol")
#		State.STATE_ATTACK:
#			print ("Attack")
	pass

func init():
	setStats(HEALTHGROWTHRATE, SPEEDGROWTHRATE, MAXSPEED, DAMAGEGROWTHRATE)
	#print ("Level:", Level, "Health: ", Health, "Speed: ", Speed, "Damage: ", Damage)