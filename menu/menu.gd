extends CanvasLayer

onready var GameManager = get_node("/root/GameManager")

# buttons
onready var start_button = get_node("VBoxContainer/StartButton")
onready var restart_button = get_node("VBoxContainer/RestartButton")
onready var options_button = get_node("VBoxContainer/OptionsButton")
onready var instructions_button = get_node("VBoxContainer/InstructionsButton")
onready var options_fullscreen_button = get_node("VBoxContainer/OptionsFullScreenButton")
onready var options_music_button = get_node("VBoxContainer/OptionsMusicButton")
onready var options_sfx_button = get_node("VBoxContainer/OptionsSfxButton")
onready var options_remap_button = get_node("VBoxContainer/OptionsRemapButton")
onready var options_return_button = get_node("VBoxContainer/OptionsReturnButton")
onready var credits_button = get_node("VBoxContainer/CreditsButton")
onready var quit_button = get_node("VBoxContainer/QuitButton")

var options_state_start = false
var options_state_restart = false

func _ready():
	pass

func _on_StartButton_pressed():
	GameManager.start_game()

func update_options_buttons():
	pass
#TODO
#	options_music_button.set_text("Music Volume: " + String(GameManager.music_level))
#	options_sfx_button.set_text("Sfx Volume: " + String(GameManager.sfx_level))
#	if GameManager.full_screen:
#		options_fullscreen_button.set_text("Go Window Mode")
#	else:
#		options_fullscreen_button.set_text("Go Full Screen")


func _on_OptionsButton_pressed():
	# store menu
	options_state_start = false
	if start_button.is_visible():
		options_state_start = true
	options_state_restart = false
	if restart_button.is_visible():
		options_state_restart = true
	# hide menu
	start_button.hide()
	restart_button.hide()
	instructions_button.hide()
	options_button.hide()
	credits_button.hide()
	quit_button.hide()
	# show options
	options_fullscreen_button.show()
	options_music_button.show()
	options_sfx_button.show()
	options_remap_button.show()
	options_return_button.show()
	update_options_buttons()
	options_return_button.grab_focus()

func _on_OptionsReturnButton_pressed():
	# hide options
	options_fullscreen_button.hide()
	options_music_button.hide()
	options_sfx_button.hide()
	options_remap_button.hide()
	options_return_button.hide()
	# restore menu
	if options_state_start:
		start_button.show()
	if options_state_restart:
		restart_button.show()
	instructions_button.show()
	options_button.show()
	if not get_tree().is_paused():
		credits_button.show()
	credits_button.show()
	quit_button.show()
	options_button.grab_focus()

func _on_QuitButton_pressed():
	GameManager.quit_game()
