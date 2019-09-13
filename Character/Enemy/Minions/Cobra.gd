extends "res://Character/Enemy/Minions/Melee.gd"

var HEALTHGROWTHRATE = 10
var SPEEDGROWTHRATE = 15
var MAXSPEED = 400
var DAMAGEGROWTHRATE = 5

func _ready():
	pass
	
func init():
	setStats(HEALTHGROWTHRATE, SPEEDGROWTHRATE, MAXSPEED, DAMAGEGROWTHRATE)
	#print ("Level:", Level, "Health: ", Health, "Speed: ", Speed, "Damage: ", Damage)