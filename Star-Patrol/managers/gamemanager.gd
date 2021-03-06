# game logic manager


# FIXME bug
# menu isn't being removed from the tree once te scene changes. why?
# as a result, pressing ui_accept will restart the first level (start button is still in focus)

extends Node

const LEVEL_BASE = preload("res://levels/level_base.gd")
const MENU_PATH = "res://menu/menu.tscn"
const MENU = preload(MENU_PATH)

# scene switching
onready var scene_manager = preload("res://managers/scenemanager.gd").new()

enum GAME_STATES { START_MENU, GAME, PAUSE_MENU, WIN_SCREEN, LOSE_SCREEN }
var current_level = 0
var current_state = GAME_STATES.START_MENU
var current_player = null

func _ready():
	set_process(true)
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print('esc pressed')
		pause()

func _process(delta):
	if current_player:
		if current_player.is_killed() or current_player.is_reached_end_of_level():
			var cur_level = scene_manager.current_scene
			if cur_level extends LEVEL_BASE:
				# ignore lives for now, respawn at the beginning of the level
				cur_level.respawn()

func pause():
	if current_state != GAME_STATES.GAME:
		return
	get_tree().set_pause(true)
	set_process_input(false)
	var menu_displayed = MENU.instance()
	menu_displayed.mode = menu_displayed.pause
	scene_manager.current_scene.add_child(menu_displayed)
	menu_displayed.raise()
	current_state = GAME_STATES.PAUSE_MENU
	TransitionScene.set_layer(5) # restore initial layer
	
func unpause(pause_menu_instance):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	scene_manager.current_scene.remove_child(pause_menu_instance)
	set_process_input(true)
	get_tree().set_pause(false)
	current_state = GAME_STATES.GAME
	
func start_level_transition(next_level):
	var title = "Get ready!"
	var level_txt = "level " + str(next_level)
	TransitionScene.init(next_level, level_txt, title)
	TransitionScene.play()
	if current_level == 1:
		# special care for the first level, since it can only be triggered by the menu
		TransitionScene.set_layer(10)

func finish_level_transition(next_level):
	current_level = next_level
	current_state = GAME_STATES.GAME
	scene_manager.goto_scene("res://levels/level" + str(next_level) + ".tscn")

func start_game():
	# todo reset score, lives, etc.
	current_level = 1
	TransitionScene.stop()
	start_level_transition(current_level)
	
func quit_game():
	get_tree().quit()
