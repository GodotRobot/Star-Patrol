extends Area2D

onready var gun_animation = get_node("AnimationPlayer")
var gun_raised = false

func _ready():
	pass
	
func raise_gun():
	if not gun_raised:
		gun_animation.play("RaiseGun")
		gun_raised = true
	
func lower_gun():
	if gun_raised:
		gun_animation.play_backwards("RaiseGun")
		gun_raised = false
