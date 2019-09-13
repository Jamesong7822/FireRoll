extends CanvasLayer

#var MAINSCENE = preload("res://Main.tscn")

func _ready():
	#Animate the background
	$AnimationPlayer.play("Moving Clouds")
	$BG.play()
	$Smoke.emitting = true
	pass


func _on_Play_Button_pressed():
	#print ("PRESS")
	var MAINSCENE = load("res://Main.tscn")
	get_tree().change_scene_to(MAINSCENE)

func _on_Quit_Button_pressed():
	get_tree().quit()
