extends Node2D

## Map Constants Here ##
#const WIDTH = 500
#const HEIGHT = 500
const RENDERSIZE = 50

const TILES = {
	"grass": 2,
	"sand": 5,
	"water": 8	
}

var openSimplexNoise

var BUSH = preload("res://Map/Objects/Bush.tscn")
var cellSize
var Seed


func _ready():
	add_to_group("Saving")
	randomize()
	openSimplexNoise = OpenSimplexNoise.new()
	Seed = randi()	
	openSimplexNoise.seed = Seed
	openSimplexNoise.octaves = 4
	openSimplexNoise.period = 15
	openSimplexNoise.lacunarity = 1.5
	openSimplexNoise.persistence = 0.75
	
	cellSize = $Ground.cell_size

	
func _physics_process(delta):
	renderWorld()
	pass
				
func renderWorld():
	# Function renders world in a zone around the player 
	var playerExists = get_tree().get_nodes_in_group("Player").size() == 1
	if playerExists:
		var playerPos = get_tree().get_nodes_in_group("Player")[0].position
		var playerTilePos = Vector2(int(playerPos.x / cellSize.x), int(playerPos.y / cellSize.y))
		#print (playerTilePos)
		
		# Get extents to render around player
	# warning-ignore:integer_division
		var leftExtent = playerTilePos.x - RENDERSIZE/2
	# warning-ignore:integer_division
		var rightExtent = playerTilePos.x + RENDERSIZE/2
	# warning-ignore:integer_division
		var topExtent = playerTilePos.y - RENDERSIZE/2
	# warning-ignore:integer_division
		var botExtent = playerTilePos.y + RENDERSIZE/2
		
		# Render in the tiles if no exist yet
		for x in range(leftExtent, rightExtent):
			for y in range(topExtent, botExtent):
				var cellExist = $Ground.get_cell(x, y)
				if cellExist != -1:
					continue
				var tileIndex = getTileIndex(openSimplexNoise.get_noise_2d(float(x), float(y)))
				$Ground.set_cellv(Vector2(x, y), tileIndex)
				if tileIndex == TILES.grass:
					addObjects(x, y, openSimplexNoise.get_noise_2d(float(x), float(y)))
			
				
			
func addObjects(x, y, value):
	if value <= 0.01:
	#var chance = randf()
	#if chance < 0.03: # Too high will crash the game
		var b = BUSH.instance()
		var bushPos = Vector2(x * cellSize.x, y * cellSize.y)
		b.position = bushPos
		$"Bushes".add_child(b)

			
func getTileIndex(noiseSample):
	if noiseSample < -0.5:
		return TILES.water
	elif noiseSample < 0:
		return TILES.sand
	else:
		return TILES.grass
		
func generateSaveData():
	var saveDict = {}
	var playerScene = get_tree().get_nodes_in_group("Player")[0]
	if playerScene.isDead:
		return
	print ("Generating Map Save Data")
	saveDict = {
			"filename": get_filename(),
			"parent": get_parent().get_path(),
			"Name": name,
			"Seed": Seed
			}

	return saveDict
	
func init():
	print ("Generating with Seed: ", Seed)
	openSimplexNoise.seed = Seed