extends Area2D

onready var sprite = get_node("Sprite")

const SPEED = 50.0 # movement speed
const MAX_DIST = 700.0 # follow the player for this maximum distance before leaving / kamikazing

var activated = false
var dir = Vector2()

func disable():
	sprite.hide()
	set_collision_mask(0)
	set_layer_mask(0)
	
func enable():
	set_collision_mask(1)
	set_layer_mask(1)
	# enter from behind, same height (y)
	var r = get_global_transform().o
	var vps = get_viewport_rect().size
	set_pos(Vector2(r.x-vps.x/2, get_pos().y))
	dir = Vector2(SPEED * 20.0, 1.0)
	sprite.show()
	
func _ready():
	disable()
	set_fixed_process(true)

func activate():
	if activated:
		return
	var player = GameManager.current_player
	if !player:
		return
	if get_pos().x < player.get_pos().x:
		print("enemy1 activated!")
		activated = true
		enable()

func _fixed_process(delta):
	activate()
	if !activated:
		return
	update_flight(delta)

func update_flight(delta):
	# do a figure of 8	
	#var r = get_viewport_transform()
	#var vps = get_viewport_rect().size
	#print('r: ', r, ', vps: ', vps)
	#if r.x < 0.2 * vps.x || r.x > 0.8 * vps.x:
	#	dir.x = -dir.x
	#if r.y < 0.1 * vps.y || r.y > 0.3 * vps.y:
	#	dir.y = -dir.y
	translate(delta * dir)
