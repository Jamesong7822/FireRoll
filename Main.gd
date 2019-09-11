extends Node2D

var thread = null

export var spawnTimer = 3
var rng = RandomNumberGenerator.new()

signal SpawnEnemy

var slimeScene = preload("res://Character/Enemy/Minions/Slime.tscn")
var GOLD = preload("res://Items/Consumables/Coins.tscn")
var PLAYER = preload("res://Character/Player/Player.tscn")

func _ready():
	rng.randomize()
	loadMap()
	#loadPlayer()
	#loadData()
	#startGame()
	# Only show Menu Page
	#loadMenuPage()
	
func loadMenuPage():
	var menuScene = load("res://HUD/Menu Page.tscn")
	get_tree().change_scene_to(menuScene)
	
func loadResource(scenePath):
	var loader = ResourceLoader.load_interactive(scenePath, "PackedScene")
	var total = loader.get_stage_count()
	var progress = $MarginContainer/CenterContainer/VBoxContainer/LoadingBar
	progress.call_deferred("set_max", total)
	var res = null
	while true:
		progress.call_deferred("set_value", loader.get_stage())
		OS.delay_msec(200.0)
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource
			res = loader.get_resource().instance()
			
			print ("Successful load")
			
			break
		elif err != OK:
			# Error
			print ("There was an error loading!")
			break
	progress.call_deferred("set_value", total)
	call_deferred("loadResourceComplete", res)
	
func loadResourceComplete(resource):
	assert (resource)
	thread.wait_to_finish()

	add_child(resource)
	loadHUD()
	loadPlayer()
	loadData()
	startGame()
	
	
func loadMap():
	thread = Thread.new()
	thread.start(self, "loadResource", "res://Map/Survival Map.tscn")

	#var a = load("res://Map/Survival Map.tscn").instance()
	#call_deferred("loadResourceComplete", a)
	
func loadHUD():
	var a = load("res://HUD/HUD.tscn").instance()
	add_child(a)
	
	
func loadPlayer():
	var a = PLAYER.instance()
	$"Survival Map/Bushes".add_child(a)
	
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
	get_tree().paused = false
	

func _on_EnemySpawnTimer_timeout():
	# Spawn Enemies
	var enemy = slimeScene.instance()
	# Get player pos
	var playerPos = get_tree().get_nodes_in_group("Player")[0].position
	# Calculate Max and Min spawn positions
	var maxSpawn = playerPos + Vector2(500, 500)
	var minSpawn = playerPos + Vector2(-500, -500)
	# Randomize position
	var enemyPos = Vector2()
	enemyPos.x = rng.randf_range(minSpawn.x, maxSpawn.x)
	enemyPos.y = rng.randf_range(minSpawn.y, maxSpawn.y)
	
	$"Survival Map/Bushes".add_child(enemy)
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
		add_child(g)
	