# game logic manager


# FIXME bug
# menu isn't being removed from the tree once te scene changes. why?
# as a result, pressing ui_accept will restart the first level (start button is still in focus)


extends Node

# scene switching
onready var scene_manager = preload("res://managers/scenemanager.gd").new()

var current_level = 0
enum GAME_STATES { START_MENU, GAME, PAUSE_MENU, WIN_SCREEN, LOSE_SCREEN }
var current_state = GAME_STATES.START_MENU
var current_player = null

func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		pause()

func pause():
	current_state = GAME_STATES.PAUSE_MENU
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
	current_state = GAME_STATES.GAME
	scene_manager.goto_scene("res://levels/Level" + str(next_level) + ".tscn")

func start_game():
	# todo reset score, lives, etc.
	current_level = 1
	TransitionScene.stop()
	start_level_transition(current_level)
	
func quit_game():
	get_tree().quit()
