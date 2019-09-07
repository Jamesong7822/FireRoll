extends CanvasLayer

func _ready():
	pass

func _physics_process(delta):
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

func _on_Back_Button_pressed():
	# Hide the Canvas Layer
	$".".layer = -1
	# Unpause the game
	get_tree().paused = false

func _on_Upgrade_Button_pressed():
	var mainScene = $".".get_parent().get_parent()
	var currentWeapon = mainScene.get_node("Outdoor Map/Bushes/Player/Base/Weapon").get_child(0)
	var HUDScene = mainScene.get_node("PAGES/HUD/Center Bot/Player Stats/Gold/HBoxContainer/Label")
	var upgradeCost = currentWeapon.calculateUpgradeCost()
	var playerScene = mainScene.get_node("Outdoor Map/Bushes/Player")
	var currentGold = playerScene.gold
	if currentGold >= upgradeCost:
		currentWeapon.upgrade()
		playerScene.gold -= upgradeCost
		HUDScene.text = str(playerScene.gold)
		mainScene.get_node("PAGES/HUD").updateShopInfo()
	
func updateShopInfo():
	# Grab current weapon stuff
	var mainScene = get_parent().get_parent()
	var currentWeapon = mainScene.get_node("Outdoor Map/Bushes/Player/Base/Weapon").get_child(0)
	var shopHUDNode = mainScene.get_node("PAGES/Shop HUD/MarginContainer/VBoxContainer/HBoxContainer")
	# Update Weapon Name
	shopHUDNode.get_node("Weapons Container/Sub Container/Name").text = currentWeapon.Name
	
	# Update Weapon Level
	shopHUDNode.get_node("Weapons Container/Sub Container/Level").text = "Level " + str(currentWeapon.Level)
	
	# Update Weapon Description
	shopHUDNode.get_node("Weapons Container/Description").text = currentWeapon.Description
	
	# Update Weapon Attributes
	# Damage
	shopHUDNode.get_node("Attributes Container/Damage/Damage Stat").text = str(currentWeapon.Damage)
	# Attack Speed
	# Critical Chance
	shopHUDNode.get_node("Attributes Container/Crit Chance/Stat").text = str(currentWeapon.CriticalChance)
	# Critical Multiplier
	shopHUDNode.get_node("Attributes Container/Crit Mult/Stat").text = str(currentWeapon.CriticalMultiplier)
	# Knockback
	shopHUDNode.get_node("Attributes Container/Knockback/Stat").text = str(currentWeapon.Knockback)
	
