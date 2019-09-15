extends Node2D

signal Collect
var PLAYER

func _ready():
	$AnimationPlayer.play("Spawn")
	PLAYER = get_tree().get_nodes_in_group("Player")[0]
	connect("Collect", PLAYER, "collectGold")

func _on_Hitbox_body_entered(body):
	if body.name == "Player":
		emit_signal("Collect")
		queue_free()
