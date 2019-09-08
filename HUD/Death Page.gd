extends Control

func _ready():
	pass


func _on_Timer_timeout():
	var mainScene = get_parent().get_parent()
	mainScene.loadMenuPage()
	queue_free()
