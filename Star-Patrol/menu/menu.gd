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

func hide_button(b, ratio):
	if b.is_visible() and b extends Button:
		# hide and thus "remove" from container
		var rect = b.get_global_rect()
		b.hide()
		# make copy and show in place of the original one
		var cpy = b.duplicate()
		cpy.set_global_pos(rect.pos)
		add_child(cpy)
		cpy.show()
		# add animations and eventually removal callback
		for i in range(0, 3):
			cpy.add_child(Tween.new())
		cpy.get_child(0).interpolate_callback(cpy, 1.0, "queue_free")
		cpy.get_child(1).interpolate_method(cpy, "set_pos", rect.pos, rect.pos - Vector2(200+500*ratio,0), 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
		cpy.get_child(2).interpolate_method(cpy, "set_opacity", 1.0, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		for c in cpy.get_children():
			c.start()

func remove_children(n):
	if n extends Button:
		for c in n.get_children():
			c.queue_free()

func show_button(b):
	b.show()
#	if b.is_hidden() and b extends Button:
#		b.show()
#		# add animations and eventually removal callback
#		for i in range(0, 3):
#			b.add_child(Tween.new())
#		#b.get_child(0).interpolate_callback(self, 1.0, "remove_children", b)
#		b.get_child(1).interpolate_method(b, "set_pos", b.get_pos() + Vector2(200+500*1,0), b.get_pos(), 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
#		b.get_child(2).interpolate_method(b, "set_opacity", 0.0, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
#		for c in b.get_children():
#			c.start()

func hide_all_buttons():
	var visible_buttons = Array()
	# collect
	options_remap_keymap.hide()
	for c in get_node("Menu").get_children():
		if c extends Button and c.is_visible():
			visible_buttons.push_back(c)
	# hide
	for c in range(0, visible_buttons.size()):
		var b = visible_buttons[c]
		hide_button(b, float(c) / visible_buttons.size())

func show_start_menu():
	hide_all_buttons()
	if GameManager.current_state == GameManager.GAME_STATES.START_MENU:
		show_button(start_button)
		start_button.grab_focus()
	else:
		show_button(restart_button)
		restart_button.grab_focus()
	show_button(instructions_button)
	show_button(options_button)
	if not get_tree().is_paused():
		show_button(credits_button)
	show_button(credits_button)
	show_button(quit_button)
	
func show_options_menu():
	hide_all_buttons()
	show_button(options_fullscreen_button)
	show_button(options_music_button)
	show_button(options_sfx_button)
	show_button(options_remap_button)
	show_button(options_return_button)
	update_options_buttons()
	options_return_button.grab_focus()

func show_options_remap_menu():
	hide_all_buttons()
	options_remap_keymap.show()
	show_button(options_remap_return_button)
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
