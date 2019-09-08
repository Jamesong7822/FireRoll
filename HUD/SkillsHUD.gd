extends CanvasLayer

func _ready():
	pass
	
func _physics_process(delta):
	update()
	
func update():
	var mainScene = get_parent().get_parent()
	var playerScene = mainScene.get_node("Outdoor Map/Bushes/Player")
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
