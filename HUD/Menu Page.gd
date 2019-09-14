extends CanvasLayer

#var MAINSCENE = preload("res://Main.tscn")

func _ready():
	#Animate the background
	$AnimationPlayer.play("Moving Clouds")
	$BG.play()
	$MarginContainer/Smoke.emitting = true
	pass


func _on_Play_Button_pressed():
	#print ("PRESS")
	var MAINSCENE = load("res://Main.tscn")
	get_tree().change_scene_to(MAINSCENE)

func _on_Quit_Button_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	var CREDITSCENE = load("res://Credits.tscn").instance()
	add_child(CREDITSCENE)


func _on_Instructions_pressed():
	var INSTRUCTIONSCENE = load("res://Instructions.tscn").instance()
	add_child(INSTRUCTIONSCENE)
