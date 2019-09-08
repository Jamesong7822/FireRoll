extends Node2D

export var spawnTimer = 3
var rng = RandomNumberGenerator.new()

signal SpawnEnemy

var slimeScene = preload("res://Character/Enemy/Minions/Slime.tscn")
var GOLD = preload("res://Items/Consumables/Coins.tscn")
var PLAYER = preload("res://Character/Player/Player.tscn")

func _ready():
	rng.randomize()
	loadData()
	startGame()
	# Only show Menu Page
	#loadMenuPage()
	
func loadMenuPage():
	get_tree().change_scene("res://HUD/Menu Page.tscn")
	
func saveData(filepath=""):
	print("Saving Game")
	var saveGame = File.new()
	saveGame.open("res://savegame.save", File.WRITE)
	var saveNodes = get_tree().get_nodes_in_group("Saving")
	for node in saveNodes:
		var nodeSaveData = node.call("generateSaveData")
		saveGame.store_line(to_json(nodeSaveData))
		
	saveGame.close()
	
func loadData(filepath=""):
	# Get var player
	var player = $"Outdoor Map/Bushes/Player"
	# Function load data from the save file
	print ("Loading Game")
	var loadGame = File.new()
	if not loadGame.file_exists("res://savegame.save"):
		return
	# Delete the loading nodes
	#var saveNodes = get_tree().get_nodes_in_group("Saving")
	#for node in saveNodes:
	#	node.queue_free()	
		
	loadGame.open("res://savegame.save", File.READ)
	while not loadGame.eof_reached():
		var currentLine = parse_json(loadGame.get_line())
		if currentLine == null:
			continue
		
		#var loadedNode = load(currentLine["filename"]).instance()
		#get_node(currentLine["parent"]).add_child(loadedNode)
		#print (currentLine)
		# Set Player stats
		var saveNode = get_node(currentLine["parent"]).get_node(currentLine["Name"])
		#print (saveNode)
		for key in currentLine.keys():
			if key == "filename" or key == "parent" or key == "Name":
				continue
				
			#print(currentLine["Name"], " Setting: ", key, " as ", currentLine[key]) 
			saveNode.set(key, currentLine[key])
			
		if currentLine["Name"] == "Basic Sword":
			var node = get_node(currentLine["parent"]).get_node(currentLine["Name"])
			node.Level = int(currentLine["Level"])
			node.Damage = int(currentLine["Damage"])
			node.Knockback = int(currentLine["Knockback"])
			node.CriticalChance = float(currentLine["CriticalChance"])
			node.CriticalMultiplier = float(currentLine["CriticalMultiplier"])
		
#		player.Health = int(currentLine["health"])
#		player.level = int(currentLine["level"])
#		player.Stamina = int(currentLine["stamina"])
#		player.experience = int(currentLine["experience"])
#		player.gold = int(currentLine["gold"])
#		player.Speed = int(currentLine["movespeed"])
	
func startGame():
	print ("STARTING GAME")
	# Reset game values here
	# Enemy Spawn Timer
	$EnemySpawnTimer.set_wait_time(spawnTimer)
	$EnemySpawnTimer.start()
	# Clear Stuff in Groups
	for child in $"Outdoor Map/Bushes/Enemy Holder".get_children():
		child.queue_free()
	for child in $"Outdoor Map/Bushes/Drops Holder".get_children():
		child.queue_free()
	$"Outdoor Map".get_tree().paused = false
	
	
	print ($"Outdoor Map/Bushes/Player/Base/Weapon".get_node("Basic Sword").Level)
	
	

func _on_EnemySpawnTimer_timeout():
	# Spawn Enemies
	var enemy = slimeScene.instance()
	# Get player pos
	var playerPos = $"Outdoor Map/Bushes/Player".position
	# Calculate Max and Min spawn positions
	var maxSpawn = playerPos + Vector2(500, 500)
	var minSpawn = playerPos + Vector2(-500, -500)
	# Randomize position
	var enemyPos = Vector2()
	enemyPos.x = rng.randf_range(minSpawn.x, maxSpawn.x)
	enemyPos.y = rng.randf_range(minSpawn.y, maxSpawn.y)
	
	$"Outdoor Map/Bushes".add_child(enemy)
	enemy.position = enemyPos
	

func _on_Player_Dead():
	# Unhide Death Screen (To DO)
	# Call Some Reset Function
	get_tree().paused = true
	$HUD.showDeathHUD()
	# Call save function
	saveData()
	
	
func dropLoot(gold, pos):
	#print ("LOOT", str(gold), " ", str(pos))
	for i in gold:
		var g = GOLD.instance()
		var newX = rng.randi_range(-20, 20)
		var newY = rng.randi_range(-20, 20)
		var newPos = pos + Vector2(newX, newY)
		g.position = newPos
		$"Outdoor Map/Bushes/Drops Holder".add_child(g)
	