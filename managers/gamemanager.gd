# game logic manager

extends Node

# scene switching
onready var scene_manager = preload("res://managers/scenemanager.gd").new()

var current_level = 0

func _ready():
	set_process(true)
	
func _process(delta):
	pass

func pause():
	TransitionScene.set_layer(5) # restore initial layer

func start_level_transition(next_level):
	var title = "Get ready!"
	var level_txt = "Level " + str(next_level)
	TransitionScene.init(next_level, level_txt, title)
	TransitionScene.play()
	if current_level == 1:
		# special care for the first level, since it can only be triggered by the menu
		TransitionScene.set_layer(10)

func finish_level_transition(next_level):
	current_level = next_level
	scene_manager.goto_scene("res://levels/Level" + str(next_level) + ".tscn")

func start_game():
	# todo reset score, lives, etc.
	current_level = 0
	TransitionScene.stop()
	start_level_transition(current_level)
	
func quit_game():
	get_tree().quit()
