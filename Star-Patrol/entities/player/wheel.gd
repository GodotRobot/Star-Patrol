extends Area2D

onready var ray_cast = get_node("RayCast2D")
var collision_pos = Vector2()
var is_colliding = false

func _draw():
	pass

func _ready():
	set_fixed_process(true)
	is_colliding = false
	
func _fixed_process(delta):
	is_colliding = false
	
	if ray_cast.is_colliding():
		var colliding_obj = ray_cast.get_collider()
		if colliding_obj extends TileMap:
			collision_pos = ray_cast.get_collision_point()
			is_colliding = true

func is_colliding():
	return is_colliding
	
func get_collision_pos():
	return collision_pos