extends Node2D

"""
Purpose
-------
Handle wave spawning of enemies

"""

# Constants Here #
const maxDist = 1500
const minDist = 500

# Variables Here #
var waveNum = 1
var numStages = 0
var stageNum = 0
var spawnHolder


export var WaveCountDown: int
export var StageCountDown: int
export var WaveCountPopUpTime: int
export var MobLevelUpRate: int

### Setup all the enemy scenes here ###
enum ENEMIES {SLIME, COBRA, FIRESPIRIT}
var ENEMYSCENES = {
	ENEMIES.SLIME: preload("res://Character/Enemy/Minions/Slime.tscn"),
	ENEMIES.COBRA: preload("res://Character/Enemy/Minions/Cobra.tscn"),
	ENEMIES.FIRESPIRIT: preload("res://Character/Enemy/Minions/Fire Spirit.tscn")	
}

func _ready():
	#add_to_group("Saving")
	randomize()
	$"Wave Timer".set("wait_time", WaveCountDown)
	$"Show Wave Count Timer".set("wait_time", WaveCountPopUpTime)
	$"Stage Timer".set("wait_time", StageCountDown)
	$"Wave Timer".start()
	$"CanvasLayer/VBoxContainer".visible = false
	$"CanvasLayer/HBoxContainer".visible = false
	init()
	
func _physics_process(delta):
	# Update Stage number
	$"CanvasLayer/HBoxContainer/Stage Num".text = "Stage: " + str(stageNum + 1)
	
	# Update progress Bar
	$"CanvasLayer/HBoxContainer/TextureProgress".max_value = numStages
	$"CanvasLayer/HBoxContainer/TextureProgress".value = stageNum + 1
	
#	var numEnemies = get_tree().get_nodes_in_group("Enemies").size()
#	if numEnemies == 0:
#		# Hide the Stage stuff
#		$"CanvasLayer/HBoxContainer".visible = false
#		# Reset Stage Counter 
#		$"Stage Timer".stop()
#		# Start Wave Timer
#		$"Wave Timer".start()
		

	

func init():
	# Set the wave counter text
	$"CanvasLayer/VBoxContainer/Wave Counter".text = "Wave " + str(waveNum)
	
func plusOrMinus():
	# Function calculates whether to plus or minus
	if randf() < 0.5:
		return -1
	return 1
	
func genNormalizedSpawnRates(spawnRates, total):
	var intermediate = []
	for i in spawnRates:
		intermediate.append(i/total)
	var cummulativeRate = 0
	var normalizedRates = []
	for i in intermediate:
		cummulativeRate += i
		normalizedRates.append(cummulativeRate)
		
	return normalizedRates
	
func genMobLevel(normalizedSpawnRates):
	# Calculate what level to spawn with normalizedspawnRates
	var randomFloat = randf()
	for rate in normalizedSpawnRates:
		if randomFloat < rate:
			return normalizedSpawnRates.bsearch(rate) + 1
	
func calculateWaveSpawns():
	# Function calculates total mobs to spawn per wave
	var spawnHolder = []
	
	# Calculate number of stages 
	numStages = int(waveNum / 5) + 1
	# Calculate total number of mobs (per stage)
	var totalMobs = numStages * 5
	# Calculate spawn rate for each mob
	var spawnRates = []
	var total = 0
	for i in range(numStages):
		# Get the non_normalized spawn rates
		var rate = -pow(((i + 1) - numStages) / numStages, 2) + 1
		total += rate
		spawnRates.append(rate)
	# Normalize the spawnRate
	spawnRates = genNormalizedSpawnRates(spawnRates, total)
	
	for i in range(numStages):
		var stageSpawns = []
		
		for j in range(totalMobs):
			var mobLevel = genMobLevel(spawnRates)
			stageSpawns.append(mobLevel)
			
		spawnHolder.append(stageSpawns)
	
	#print ("Computed: ", spawnHolder)
		
	return spawnHolder
		
func spawnHandler():
	var toSpawn = spawnHolder[stageNum]
	for mobLevel in toSpawn:
		var mobIndex = randi() % ENEMIES.size()
		var mob = ENEMYSCENES[mobIndex].instance()
		spawn(mob, mobLevel)
		
func spawn(enemy, level):
	# Function spawns enemy at appropriate distance from player
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	var playerPos = playerScene.position
	
	# Calculate extents to spawn enemy in		
	var offsetPos = Vector2(rand_range(minDist, maxDist), rand_range(minDist, maxDist)) * Vector2(plusOrMinus(), plusOrMinus())
	var spawnPos = playerPos + offsetPos
	
	enemy.position = spawnPos
	enemy.Level = level
	enemy.init()
	
	var spawnHolder = get_parent().get_node("Survival Map/Bushes")
	spawnHolder.add_child(enemy)

func _on_Wave_Timer_timeout():
	# Show wave num 
	$"CanvasLayer/VBoxContainer".visible = true
	# Spawn WAVESSS
	spawnHolder = calculateWaveSpawns()
	stageNum = 0
	spawnHandler()
	$"Stage Timer".start()
	$"Show Wave Count Timer".start()


func _on_Show_Wave_Count_Timer_timeout():
	# Hide Wave Counter
	$"CanvasLayer/VBoxContainer".visible = false
	# Increment wave Num by 1
	waveNum += 1
	# Update wave counter text
	init()
	$"CanvasLayer/HBoxContainer".visible = true


func _on_Stage_Timer_timeout():
	$"Stage Timer".start()
	stageNum += 1
	
	if stageNum < numStages:
		spawnHandler()
	else:
		stageNum = numStages
	var numEnemies = get_tree().get_nodes_in_group("Enemies").size()
	#print (numEnemies)
	if stageNum >= numStages and numEnemies == 0:
		$"CanvasLayer/HBoxContainer".visible = false
		# Reset stageNum and start wave timer
		stageNum = 0 
		$"Wave Timer".start()
	
