extends TextureProgress

func _ready():
	pass
	
func _physics_process(delta):
	var playerExists = get_tree().get_nodes_in_group("Player").size() == 1
	if playerExists:
		var playerScene = get_tree().get_nodes_in_group("Player")[0]
		
		var EXPMAX = playerScene.calculateEXP()
		max_value = EXPMAX
		value = playerScene.experience
		
