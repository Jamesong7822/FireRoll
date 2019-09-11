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


func _ready():
	randomize()
	openSimplexNoise = OpenSimplexNoise.new()
	openSimplexNoise.seed = randi()
	
	openSimplexNoise.octaves = 4
	openSimplexNoise.period = 15
	openSimplexNoise.lacunarity = 1.5
	openSimplexNoise.persistence = 0.75
	
	cellSize = $Ground.cell_size
	#generateWorld()
	startRender()
	
# warning-ignore:unused_argument
func _physics_process(delta):
	renderWorld()
	pass
	
#func generateWorld():
#	var total = WIDTH * HEIGHT
#	for x in WIDTH:
#		for y in HEIGHT:
#			var tileIndex = getTileIndex(openSimplexNoise.get_noise_2d(float(x), float(y)))
#			$Ground.set_cellv(Vector2(x - WIDTH / 2, y - HEIGHT / 2), tileIndex)
#			if tileIndex == TILES.grass:
#				addObjects(x - WIDTH/2, y-HEIGHT/2)
#
func startRender():
	# Function starts rendering a small zone around spawn pos
# warning-ignore:integer_division
	var leftExtent = - RENDERSIZE/2
# warning-ignore:integer_division
	var rightExtent =  RENDERSIZE/2
# warning-ignore:integer_division
	var topExtent =  - RENDERSIZE/2
# warning-ignore:integer_division
	var botExtent = RENDERSIZE/2
	
	for x in range(leftExtent, rightExtent):
		for y in range(topExtent, botExtent):
			#print ("X: ", x, " Y: ", y)
			var tileIndex = getTileIndex(openSimplexNoise.get_noise_2d(float(x), float(y)))
			#print ("TileIndex: ", tileIndex)
			$Ground.set_cellv(Vector2(x, y), tileIndex)
			if tileIndex == TILES.grass:
				addObjects(x, y)
				
func renderWorld():
	# Function renders world in a zone around the player 
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
				addObjects(x, y)
			
				
			
func addObjects(x, y):
	var chance = randf()
	if chance < 0.03: # Too high will crash the game
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
