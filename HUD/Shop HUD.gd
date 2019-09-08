extends CanvasLayer

func _ready():
	pass

func _physics_process(delta):
	updateShopInfo()
	var mainScene = $".".get_parent().get_parent()
	var currentWeapon = mainScene.get_node("Outdoor Map/Bushes/Player/Base/Weapon").get_child(0)
	var upgradeCost = currentWeapon.calculateUpgradeCost()
	$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Button Container/Upgrade Button".text = "Upgrade ("+str(upgradeCost)+ ")"
	var playerScene = mainScene.get_node("Outdoor Map/Bushes/Player")

	var currentGold = playerScene.gold
	if currentGold >= upgradeCost:
		$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Button Container/Upgrade Button".disabled = false
	else:
		$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Button Container/Upgrade Button".disabled = true
	pass


func _on_Upgrade_Button_pressed():
	var mainScene = $".".get_parent().get_parent()
	var currentWeapon = mainScene.get_node("Outdoor Map/Bushes/Player/Base/Weapon").get_child(0)
	var HUDScene = mainScene.get_node("HUD/Center Bot/Player Stats/Gold/HBoxContainer/Label")
	var upgradeCost = currentWeapon.calculateUpgradeCost()
	var playerScene = mainScene.get_node("Outdoor Map/Bushes/Player")
	var currentGold = playerScene.gold
	if currentGold >= upgradeCost:
		currentWeapon.upgrade()
		playerScene.gold -= upgradeCost
		HUDScene.text = str(playerScene.gold)

	
func updateShopInfo():
	# Grab current weapon stuff
	var mainScene = get_parent().get_parent()
	var currentWeapon = mainScene.get_node("Outdoor Map/Bushes/Player/Base/Weapon").get_child(0)
	
	# Update Weapon Name
	$"MarginContainer/VBoxContainer/HBoxContainer/Weapons Container/Sub Container/Name".text = currentWeapon.Name
	
	# Update Weapon Level
	$"MarginContainer/VBoxContainer/HBoxContainer/Weapons Container/Sub Container/Level".text = "Level " + str(currentWeapon.Level)
	
	# Update Weapon Description
	$"MarginContainer/VBoxContainer/HBoxContainer/Weapons Container/Description".text = currentWeapon.Description
	
	# Update Weapon Attributes
	# Damage
	$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Damage/Damage Stat".text = str(currentWeapon.Damage)
	# Attack Speed
	# Critical Chance
	$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Crit Chance/Stat".text = str(currentWeapon.CriticalChance)
	# Critical Multiplier
	$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Crit Mult/Stat".text = str(currentWeapon.CriticalMultiplier)
	# Knockback
	$"MarginContainer/VBoxContainer/HBoxContainer/Attributes Container/Knockback/Stat".text = str(currentWeapon.Knockback)
	


func _on_Back_Button_pressed():
	get_tree().paused = false
	queue_free()
