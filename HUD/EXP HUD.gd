extends TextureProgress

func _ready():
	pass
	
func _physics_process(delta):
	var mainScene = $".".get_parent().get_parent().get_parent()
	var playerScene = mainScene.get_node("Outdoor Map/Bushes/Player")
	
	var EXPMAX = playerScene.calculateEXP()
	max_value = EXPMAX
	value = playerScene.experience
	
