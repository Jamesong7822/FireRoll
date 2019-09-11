extends TextureProgress

func _ready():
	pass
	
func _physics_process(delta):
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	
	var EXPMAX = playerScene.calculateEXP()
	max_value = EXPMAX
	value = playerScene.experience
	
