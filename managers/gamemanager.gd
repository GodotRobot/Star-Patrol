# game logic manager

extends Node

# scene switching
const scene_manager = preload("res://managers/scenemanager.gd")

func _ready():
	set_process(true)
	
func _process(delta):
	pass