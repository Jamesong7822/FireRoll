extends CanvasLayer

func _ready():
	pass
	
func _physics_process(delta):
	update()
	
func update():
	var mainScene = get_parent().get_parent()
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	# Get amount of skill points available
	var skillPoints = playerScene.skillPoints
	# Update the skill points
	$"MarginContainer/MarginContainer/VBoxContainer/Skill Points".text = "Skill Points: " + str(skillPoints)
	# Disable buttons if necessary
	if skillPoints == 0:
		for button in get_tree().get_nodes_in_group("Upgrade"):
			button.disabled = true


func _on_Back_Button_pressed():
	get_tree().paused = false
	queue_free()


func _on_Health_pressed():
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	playerScene.skillUp("Health")
	$Upgrade.play()
	playerScene.skillPoints -=1


func _on_Speed_pressed():
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	playerScene.skillUp("Speed")
	$Upgrade.play()
	playerScene.skillPoints -=1


func _on_Stamina_pressed():
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	playerScene.skillUp("Stamina")
	$Upgrade.play()
	playerScene.skillPoints -=1
