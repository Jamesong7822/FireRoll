extends CanvasLayer

var ShopHUD = preload("res://HUD/Shop HUD.tscn")
var SkillsHUD = preload("res://HUD/SkillsHUD.tscn")
var DeathHUD = preload("res://HUD/Death Page.tscn")

func _ready():
	#var player = get_parent().get_parent().get_node("Outdoor Map/Bushes/Player")
	#$"Center Bot/Player Stats/Gold/HBoxContainer/Label".text = str(player.gold)
	# Show only main HUD
	pass

func _on_Player_Health_Changed(value):
	$"Center Bot/Player Stats/Health Bar/Health Progress Bar".set_value(value)
	

func _on_Player_Stamina_Changed(value):
	$"Center Bot/Player Stats/Stamina Bar/Stamina Progress Bar".set_value(value)


func _on_Player_Gold_Changed(Gold):
	$"Center Bot/Player Stats/Gold/HBoxContainer/Label".text = str(Gold)

func showDeathHUD():
	var a = DeathHUD.instance()
	add_child(a)


func _on_ShopButton_pressed():

	var a = ShopHUD.instance()
	add_child(a)
	get_tree().paused = true
	


func _on_Skill_Up_Button_pressed():
	var a = SkillsHUD.instance()
	add_child(a)
	get_tree().paused = true
	


func _on_Menu_Button_pressed():
	# save Stuff
	var mainScene = get_parent()
	mainScene.saveData()
	get_tree().paused = true
	$Popup.popup()
	$Popup/Timer.start()
	

func _on_Timer_timeout():
	var mainScene = get_parent()
	mainScene.loadMenuPage()
