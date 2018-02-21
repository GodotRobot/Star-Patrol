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
	# reset raise gun animation
	gun_animation.seek(0, true)
	is_raised = false
	show()
