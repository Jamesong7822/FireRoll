extends "res://Character/Enemy/Minions/Melee.gd"

var HEALTHGROWTHRATE = 5
var SPEEDGROWTHRATE = 10
var MAXSPEED = 300
var DAMAGEGROWTHRATE = 15

func _ready():
	
	pass

func init():
	setStats(HEALTHGROWTHRATE, SPEEDGROWTHRATE, MAXSPEED, DAMAGEGROWTHRATE)
	#print ("Level:", Level, "Health: ", Health, "Speed: ", Speed, "Damage: ", Damage)