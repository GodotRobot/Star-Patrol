extends Area2D

var activated = false
const SPEED = 50.0
var course = 0
var course_dir

func _ready():
	set_fixed_process(true)

func activate():
	if activated:
		return
	var player = GameManager.current_player
	if !player:
		return
	var player_dist = get_pos().x - player.get_pos().x
	if player_dist < 800:
		print("enemy1 activated!")
		activated = true

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
