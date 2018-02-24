extends Area2D

onready var gun_animation = get_node("AnimationPlayer")
var is_raised = false

func _ready():
	pass
	
func raise():
	if not is_raised:
		gun_animation.play("RaiseGun")
		is_raised = true
	
func lower():
	if is_raised:
		gun_animation.play_backwards("RaiseGun")
		is_raised = false

func reset():
	# reset raised gun animation
	gun_animation.seek(0, true)
	is_raised = false
	show()

func is_animation_finished():
	return gun_animation.is_playing() == false

func is_raised():
	return is_raised

# return the offset to get the proper bullet exit pos
func get_offset():
	var cur_offset = Vector2()
	if is_raised:
		cur_offset = Vector2(-20, -58)
	else:
		cur_offset = Vector2(10, -30)
	return cur_offset
