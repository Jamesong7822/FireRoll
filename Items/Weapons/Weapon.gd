extends "res://Items/item.gd"

export var Damage: int
export var DamageRange: int
export var Knockback: int
export var Level: int
#export var AttackSpeed: float
export var CriticalChance: float
export var CriticalMultiplier: float


func _ready():
	add_to_group("Saving")
	pass

func init():
	pass