extends Area2D

# ray detecting collision with the ground tiles
onready var ray_cast = get_node("RayCast2D")
# the turning wheel animation player
onready var wheel_anim = get_node("AnimationPlayer")

var collision_pos = Vector2()
var radius = 0.0
var on_ground = false


func _ready():
	set_fixed_process(true)
	on_ground = false
	radius = get_node("Sprite").get_texture().get_width() / 2.0
	wheel_anim.play("WheelRotation")
	
func _fixed_process(delta):
	if ray_cast.is_colliding():
		var colliding_obj = ray_cast.get_collider()
		if colliding_obj extends TileMap:
			collision_pos = ray_cast.get_collision_point()
			collision_pos.y -= radius # wheel radius correction

func is_on_ground():
	return  on_ground

# return the position of the wheel when taking into account the ray cast point on the ground
func get_colliding_position():
	var original_pos = get_global_transform().get_origin()
	var offset = Vector2(0, collision_pos.y - original_pos.y)
	return get_pos() + offset
	
func reset_ground_col_check():
	on_ground = false
	
func _on_Wheel_body_enter(body):
	var groups = body.get_groups()
	if groups.has("ground"):
		# the wheel is in contact with the ground tiles
		on_ground = true
	
func set_rotation_speed(speed):
	wheel_anim.set_speed(speed)
