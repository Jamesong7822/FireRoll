extends "res://Items/Weapons/Weapon.gd"

### CONSTANTS
const ATTACKGROWTH = 5
const KNOCKBACKGROWTH = 1
const CRITCHANCEGROWTH = 1
const CRITMULTIPLIERGROWTH = 0.1

var player
signal Attack

func _ready():
	#Name = $".".name
	$AnimationPlayer.play("Setup")
	$"Attack Up Area/CollisionShape2D".disabled = true
	$"Attack Down Area/CollisionShape2D".disabled = true
	player = get_tree().get_nodes_in_group("Player")[0]
	connect("Attack", player, "on_Attack")

	pass


func _on_Area2D_body_entered(body):
	var enemyGroup = get_tree().get_nodes_in_group("Enemies")
	if body in enemyGroup:
		body.knockback = Knockback
		body.hit(Damage)
		
		
func on_Up_Attack():
	$AnimationPlayer.current_animation = "Attack_Up"
	#yield($AnimationPlayer, "animation_finished")
	
	
func on_Down_Attack():
	$AnimationPlayer.current_animation = "Attack_Down"
	#yield($AnimationPlayer, "animation_finished")

		
func on_Horizontal_Attack():
	$AnimationPlayer.current_animation = "Attack_Horizontal"
	#yield($AnimationPlayer, "animation_finished")
	
func expendStamina():
	emit_signal("Attack")
	
func on_Move():
	$AnimationPlayer.queue("Move")
	
	
	
#=====================================================================================
	
### TO DO make the below functions an inherited function from weapon.gd!!!
func calculateUpgradeCost():
	# Takes current level of weapon and calculates upgrade cost!
	var upgradeCost = int(Level * exp(1.2) * 25)
	#print ("Upgrade Cost: ", upgradeCost)
	return upgradeCost
	
func upgrade():
	Level += 1
	Damage += ATTACKGROWTH
	Knockback += KNOCKBACKGROWTH
	CriticalChance += CRITCHANCEGROWTH
	CriticalMultiplier += CRITMULTIPLIERGROWTH
	
func generateSaveData():
	print ("Generating Weapon Save Data")
	var saveDict = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"Name": Name,
		"Level": Level,
		"Damage": Damage,
		"Knockback": Knockback,
		"CriticalChance": CriticalChance,
		"CriticalMultiplier": CriticalMultiplier
		}
		
	return saveDict
