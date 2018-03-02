extends Area2D

# bullet default distance limit and current value in pixels
var bullet_max_distance = 800
var bullet_cur_distance = 0

var bullet_velocity = Vector2()

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	var cur_pos = get_pos()
	cur_pos += bullet_velocity * delta
	set_pos(cur_pos)
	bullet_cur_distance += bullet_velocity.length() * delta
	if bullet_cur_distance > bullet_max_distance:
		# max distance reached, end bullet
		disable()


func init(global_pos, velocity, distance = 0):
	bullet_velocity = velocity
	if distance != 0:
		bullet_max_distance = distance
	bullet_cur_distance = 0
	set_global_pos(global_pos)

func disable():
	hide()
	queue_free()
