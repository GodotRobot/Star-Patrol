# Simple action remapper. Supports joystick and keyboard.

extends VBoxContainer

var ongoing = null

class Action:
	var name
	var evtkey
	var evtjoy
	var button
	var lbl_key
	var lbl_joy
	func event_key_str():
		if evtkey != null:
			return OS.get_scancode_string(evtkey.scancode)
		return "unmapped"
	func event_joy_str():
		if evtjoy != null:
			if evtjoy.type == InputEvent.JOYSTICK_BUTTON:
				return 'Joystick ' + str(evtjoy.device) + ' Button ' + str(evtjoy.button_index)
			elif evtjoy.type == InputEvent.JOYSTICK_MOTION:
				var val = '+' + str(evtjoy.axis)
				if evtjoy.value < 0:
					val = '-' + str(evtjoy.axis)
				return 'Joystick ' + str(evtjoy.device) + ' Axis ' + val
		return "unmapped"
	func events_str():
		var s = ''
		if evtkey != null:
			s += event_key_str()
			if evtjoy != null:
				s += ' or '
		if evtjoy != null:
			s += event_joy_str()
		return s
		
var actions_ = Array()

# respond to the cancel key pressed. return true if remapping can end, or
# false if this cancel request is handled internally
func cancel():
	if ongoing == null:
		return true
	return false

func show():
	print("show")
	.show()
	
func hide():
	print("hide")
	.hide()

func filter_key_event(events):
	for e in events:
		if e.type == InputEvent.KEY:
			return e
	return null

func filter_joy_event(events):
	for e in events:
		if e.type == InputEvent.JOYSTICK_BUTTON or e.type == InputEvent.JOYSTICK_MOTION:
			return e
	return null
	
func init_actions():
	# only go over event the the designer has put in the editor
	for c in get_children():
		var n = Action.new()
		n.name = c.get_name()
		n.evtkey = filter_key_event(InputMap.get_action_list(n.name))
		n.evtjoy = filter_joy_event(InputMap.get_action_list(n.name))
		n.button = c
		n.button.set_text(n.name)
		n.lbl_key = c.get_node("key")
		n.lbl_key.set_text(n.event_key_str())
		n.lbl_joy = c.get_node("joy")
		n.lbl_joy.set_text(n.event_joy_str())
		actions_.append(n)

func print_actions():
	for a in actions_:
		print(a.name, ": ", a.events_str())
		
func _ready():
	init_actions()
	print_actions()
	for a in actions_:
		a.button.connect("pressed", self, "_some_button_pressed", [a.button])

func get_action_by_name(name):
	for a in actions_:
		if a.name == name:
			return a
	return null
	
func _some_button_pressed(button):
	var name = button.get_name()
	print('mapping ' + name + '...')
	ongoing = get_action_by_name(name)
	ongoing.button.set_text("press new key")
	set_process_input(true)

# will be called only during action capture (remapping)
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		# ignore and wait for next event
		return
	if (event.type == InputEvent.KEY and event.is_action_pressed("ui_cancel")) or \
		(event.type == InputEvent.MOUSE_BUTTON):
		# cancel mapping
		set_process_input(false)
		ongoing = null
		init_actions()
		return
		
	if event.type == InputEvent.KEY:
		ongoing.evtkey = event
	if event.type == InputEvent.JOYSTICK_MOTION or event.type == InputEvent.JOYSTICK_BUTTON:
		ongoing.evtjoy = event
		
	InputMap.erase_action(ongoing.name)
	InputMap.add_action(ongoing.name)
	if ongoing.evtkey != null:
		InputMap.action_add_event(ongoing.name, ongoing.evtkey)
	if ongoing.evtjoy != null:
		InputMap.action_add_event(ongoing.name, ongoing.evtjoy)
	set_process_input(false)
	ongoing = null
	init_actions()
