extends Area2D

# bullet life time in sec
var bullet_max_duration = 1.0
var bullet_cur_duration = 0

var bullet_velocity = Vector2()


func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	var cur_pos = get_pos()
	cur_pos += bullet_velocity * delta
	set_pos(cur_pos)
	
	bullet_cur_duration += delta
	if bullet_cur_duration > bullet_max_duration:
		# bullet ran out of time, remove it
		queue_free()

func init(global_pos, velocity, duration = 0):
	bullet_velocity = velocity
	if duration != 0:
		bullet_max_duration = duration
	bullet_cur_duration = 0
	set_global_pos(global_pos)
