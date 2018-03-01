extends Area2D

onready var sprite = get_node("Sprite")

var activated = false
const SPEED = 50.0
var course = 0
var course_dir

func disable():
	sprite.hide()
	set_collision_mask(0)
	set_layer_mask(0)
	
func enable():
	sprite.show()
	set_collision_mask(2)
	set_layer_mask(1)
	# enter from behind, same height (y)
	
	#if player:
	#	var cam = player.get_node("Camera2D")
	#	if cam:
	#		var vp = cam.get_custom_viewport()
	#		set_pos(Vector2(player.get_pos().x, get_pos().y))
	
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

func update_flight(delta):
	if course == 0:
		course = int(rand_range(10, 40))
		course_dir = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	course = course - 1
	var rnd = SPEED * delta * Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	set_pos(get_pos() + rnd + course_dir * delta * 70.0)

func _fixed_process(delta):
	activate()
	if !activated:
		return
	update_flight(delta)


func _on_Enemy1_area_enter(area):
	var groups = area.get_groups()
	if groups.has("player_bullet"):
		print("collision with bullet")
