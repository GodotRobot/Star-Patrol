extends Node2D

onready var player = get_node("Player")

# level starting point
export (int, 550) var respawn_pos_x
export (int, 617) var respawn_pos_y

func _ready():
	# place the player at the starting point
	respawn()

func respawn():
	player.set_pos(Vector2(respawn_pos_x, respawn_pos_y))
	player.activate()
