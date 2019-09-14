extends "res://Character/Character.gd"

## Stat Growth ##
var HEALTHGROWTH = 20
var SPEEDGROWTH = 10
var STAMINAGROWTH = 20

const ACC = 30
const DACC = ACC * 1.5
enum State {STATE_MOVE, STATE_IDLE, STATE_ATTACK, STATE_DAMAGED}
enum Facing {FACE_RIGHT, FACE_LEFT, FACE_UP, FACE_DOWN}
enum WEAPONS {WEAPON_BASIC_SWORD}

var experience = 0
var level = 1
var skillPoints = 0
var currentHealth
var currentStamina
var currentState
var currentWeapon
var currentFacing
var Stamina = 100
var gold = 0
var isDead = false

onready var basicSword = preload("res://Items/Weapons/Melee/Basic Sword.tscn")
export var HUDSCENE = preload("res://HUD/HUD.tscn")
var HEALTHBAR = preload("res://HUD/Health Bar.tscn")
var STAMINABAR = preload("res://HUD/Stamina Bar.tscn")

signal Health_Changed(Health)
signal Stamina_Changed(Stamina)
signal Gold_Changed(Gold)
signal Dead

# Signals for Weapon Scenes
signal HorizontalAttack
signal UpAttack
signal DownAttack
signal WeaponMove

var moveVec = Vector2(0, 0)
var weaponNode

func _ready():
	add_to_group("Player")
	add_to_group("Saving")
	currentHealth = Health
	currentStamina = Stamina
	currentState = State.STATE_IDLE
	currentWeapon = WEAPONS.WEAPON_BASIC_SWORD
	
	# Equip Weapon
	var weapon = basicSword.instance()
	weapon.scale.x = 1
	weapon.set_position($WeaponPos.position)
	
	$Base/Weapon.add_child(weapon)

	
	# Connect Signals
	connect("UpAttack", $Base/Weapon.get_child(0), "on_Up_Attack")
	connect("DownAttack", $Base/Weapon.get_child(0), "on_Down_Attack")
	connect("HorizontalAttack", $Base/Weapon.get_child(0), "on_Horizontal_Attack")
	connect("WeaponMove", $Base/Weapon.get_child(0), "on_Move")
	weaponNode = weapon
	
	
	$Base/Blood.hide()
	$Base/LevelUp.hide()
	
	# Update HUD
	var HUD = get_parent().get_parent().get_parent().get_node("HUD")
	connect("Health_Changed", HUD, "_on_Player_Health_Changed")
	connect("Stamina_Changed", HUD, "_on_Player_Stamina_Changed")
	connect("Gold_Changed", HUD, "_on_Player_Gold_Changed")
	emit_signal("Gold_Changed", gold)
	
	
	var MAIN = get_parent().get_parent().get_parent()
	connect("Dead", MAIN, "_on_Player_Dead")
	

func _physics_process(delta):
	#print ("Level: ", level)
	#print ("Gold: ", gold)
	
	movementHandler(delta)
	animationHandler()
	hasLevelUp()
	var staminaRate = Stamina * 0.001
	currentStamina += staminaRate
	currentStamina = clamp(currentStamina, 0, Stamina)
	emit_signal("Health_Changed", currentHealth)
	emit_signal("Stamina_Changed", currentStamina)
	emit_signal("Gold_Changed", gold)

	match currentState:
		State.STATE_MOVE:
			# Get weapon
#			var weapon = $Base/Weapon.get_child(0)
#			weapon.get_node("AnimationPlayer").play("Move")
			emit_signal("WeaponMove")
		
			
		State.STATE_ATTACK:
			if currentFacing == Facing.FACE_UP or currentFacing == Facing.FACE_LEFT:
				$Base/Weapon.show_behind_parent = true
				
			else:
				$Base/Weapon.show_behind_parent = false
				
			if currentFacing == Facing.FACE_UP:
				emit_signal("UpAttack")
				
			elif currentFacing == Facing.FACE_DOWN:
				emit_signal("DownAttack")
				
			else:
				emit_signal("HorizontalAttack")
				
			currentState = State.STATE_IDLE
				
		State.STATE_IDLE:
			var weapon = $Base/Weapon.get_child(0)
			#weapon.get_node("AnimationPlayer").play("Setup")
			match currentFacing:
				Facing.FACE_UP:
					$Base/Weapon.show_behind_parent = true
				Facing.FACE_LEFT:
					$Base/Weapon.show_behind_parent = true
				_:
					$Base/Weapon.show_behind_parent = false
			
	
	if Input.is_mouse_button_pressed(1) and currentStamina > weaponNode.Weight:
		currentState = State.STATE_ATTACK
		
	if Input.is_mouse_button_pressed(1) and currentStamina < weaponNode.Weight:
		# Play Not enough energy sound
		if not $NoEnergy.is_playing():
			$NoEnergy.play()
		
func movementHandler(delta):
	moveVec = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		# MoveVec
		moveVec += Vector2(0, -1)
		currentState = State.STATE_MOVE
		currentFacing = Facing.FACE_UP
		
	if Input.is_action_pressed("ui_down"):
		# MoveVec
		moveVec += Vector2(0, 1)
		currentState = State.STATE_MOVE
		currentFacing = Facing.FACE_DOWN
		
	if Input.is_action_pressed("ui_left"):
		# MoveVec
		moveVec += Vector2(-1, 0)
		currentState = State.STATE_MOVE
		currentFacing = Facing.FACE_LEFT
		
	if Input.is_action_pressed("ui_right"):
		# MoveVec
		moveVec += Vector2(1, 0)
		currentState = State.STATE_MOVE
		currentFacing = Facing.FACE_RIGHT
		
	if moveVec.length() == 0 and currentState != State.STATE_ATTACK:
		currentState = State.STATE_IDLE
		
	# Normalize the moveVec
	moveVec = moveVec.normalized()
	
	# Apply the moveVec to position
	move_and_slide(moveVec * Speed)
		
func animationHandler():
	$Base/Weapon.show_behind_parent=false
	if moveVec.y > 0 and moveVec.x == 0:
		# Going Down
		$AnimationPlayer.play("Down")
		$Base/Weapon.get_child(0).scale.x = 1
		$Base/Weapon.get_child(0).position = $WeaponPos.position
	elif moveVec.y < 0 and moveVec.x == 0:
		# Going Up
		$AnimationPlayer.play("Up")
		$Base/Weapon.show_behind_parent = true
		$Base/Weapon.get_child(0).scale.x = 1
		$Base/Weapon.get_child(0).position = $WeaponPos.position
	elif moveVec.x < 0:
		# Going Left
		$AnimationPlayer.play("Left")
		$Base/Weapon.show_behind_parent = true
		$Base/Weapon.get_child(0).scale.x = -1
		$Base/Weapon.get_child(0).position = $WeaponPos_Left.position
	elif moveVec.x > 0:
		# Going Right
		$AnimationPlayer.play("Right")
		$Base/Weapon.get_child(0).scale.x = 1
		$Base/Weapon.get_child(0).position = $WeaponPos_Right.position
		

func on_Attack():
	currentStamina -= weaponNode.Weight

func on_Hit(damage):
	currentHealth -= damage
	if currentHealth <= 0:
		isDead = true
		emit_signal("Dead")
		
	currentState = State.STATE_DAMAGED
	$Effects.current_animation = "Take_Damage"
	
	$Hurt.play()

		
func collectGold():
	gold += 1
	if not $"Coins PickUp".is_playing():
		$"Coins PickUp".play()
	emit_signal("Gold_Changed", gold)
	
func addEXP(EXP):
	#print (EXP)
	experience += EXP
	
func hasLevelUp():
	# Function calculates current level based on EXP
	var currentlvl = int(0.1 * sqrt(experience))
	if currentlvl > level:
		level = currentlvl
		skillPoints += 1
		$Effects.current_animation = "Level Up"
		currentHealth = Health
		currentStamina = Stamina
		$"Level Up".play()
		
	
	
func calculateEXP():
	# Function calculates how much EXP required for next level up
	if level == 1:
		return [0, pow((level + 1)/0.1, 2)]
	return [pow((level)/0.1, 2), pow((level + 1)/0.1, 2)]
	
func generateSaveData():
	print ("Generating Player Save Data")
	var saveDict = {}
	if not isDead:
		saveDict = {
			"filename": get_filename(),
			"parent": get_parent().get_path(),
			"Name": Name,
			"level": level,
			"experience": experience,
			"currentWeapon": currentWeapon,
			"skillPoints": skillPoints,
			"gold": gold,
			"Health": Health,
			"Stamina": Stamina,
			"Speed": Speed,
			"currentHealth": currentHealth,
			"currentStamina": currentStamina,
			"isDead": isDead,
			"pos_x": position.x,
			"pos_y": position.y
			}
	else:
		saveDict = {
			"filename": get_filename(),
			"parent": get_parent().get_path(),
			"Name": Name,
			"level": level,
			"experience": experience,
			"currentWeapon": currentWeapon,
			"skillPoints": skillPoints,
			"gold": gold,
			"Health": Health,
			"Stamina": Stamina,
			"Speed": Speed,
			"pos_x": 0,
			"pos_y": 0
			}
		
	return saveDict
	
func skillUp(skill):
	match skill:
		"Health":
			Health += HEALTHGROWTH
			
			
		"Stamina":
			Stamina += STAMINAGROWTH
			
		"Speed":
			Speed += SPEEDGROWTH
			
func init():
	pass