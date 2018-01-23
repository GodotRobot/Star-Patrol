extends CanvasLayer

onready var GameManager = get_node("/root/GameManager")

func _ready():
	pass

func _on_StartButton_pressed():
	GameManager.start_game()
