extends Area2D

var velocity = Vector2()


func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	translate(velocity * delta)

func set_velocity(x, y):
	velocity = Vector2(x, y)

func _on_HoleBullet_body_enter(body):
	var groups = body.get_groups()
	if groups.has("ground"):
		print("hole bullet hit the ground")
		queue_free()
