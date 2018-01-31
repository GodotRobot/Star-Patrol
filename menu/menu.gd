extends CanvasLayer

# buttons
onready var start_button = get_node("Menu/StartButton")
onready var restart_button = get_node("Menu/RestartButton")
onready var options_button = get_node("Menu/OptionsButton")
onready var instructions_button = get_node("Menu/InstructionsButton")
onready var options_fullscreen_button = get_node("Menu/OptionsFullScreenButton")
onready var options_music_button = get_node("Menu/OptionsMusicButton")
onready var options_sfx_button = get_node("Menu/OptionsSfxButton")
onready var options_remap_button = get_node("Menu/OptionsRemapButton")
onready var options_remap_keymap = get_node("Menu/Keymap")
onready var options_remap_return_button = get_node("Menu/OptionsRemapReturnButton")
onready var options_return_button = get_node("Menu/OptionsReturnButton")
onready var credits_button = get_node("Menu/CreditsButton")
onready var quit_button = get_node("Menu/QuitButton")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if quit_button.is_visible():
			GameManager.quit_game()
		elif options_return_button.is_visible():
			show_start_menu()
		elif options_remap_return_button.is_visible():
			if options_remap_keymap.cancel():
				show_options_menu()

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

func hide_all_buttons():
	options_remap_keymap.hide()
	for c in get_node("Menu").get_children():
		if c extends Button:
			c.hide()

func show_start_menu():
	hide_all_buttons()
	if GameManager.current_state == GameManager.GAME_STATES.START_MENU:
		start_button.show()
		start_button.grab_focus()
	else:
		restart_button.show()
		restart_button.grab_focus()
	instructions_button.show()
	options_button.show()
	if not get_tree().is_paused():
		credits_button.show()
	credits_button.show()
	quit_button.show()
	
func show_options_menu():
	hide_all_buttons()
	options_fullscreen_button.show()
	options_music_button.show()
	options_sfx_button.show()
	options_remap_button.show()
	options_return_button.show()
	update_options_buttons()
	options_return_button.grab_focus()

func show_options_remap_menu():
	hide_all_buttons()
	options_remap_keymap.show()
	options_remap_return_button.show()
	options_remap_return_button.grab_focus()
	
# button press signal handlers

func _on_OptionsButton_pressed():
	show_options_menu()

func _on_OptionsRemapButton_pressed():
	show_options_remap_menu()
	
func _on_OptionsRemapReturnButton_pressed():
	show_options_menu()
	
func _on_OptionsReturnButton_pressed():
	show_start_menu()

func _on_QuitButton_pressed():
	GameManager.quit_game()
