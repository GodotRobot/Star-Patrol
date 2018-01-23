# game logic manager

extends Node

# scene switching
onready var scene_manager = preload("res://managers/scenemanager.gd").new()

func _ready():
	set_process(true)
	
func _process(delta):
	pass
	
func start_game():
	# todo reset score, lives, etc.
	scene_manager.goto_scene("res://levels/Level1.tscn")
