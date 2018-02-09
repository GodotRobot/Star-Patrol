extends Area2D

# starting speed
const DEFAULT_SPEED = 3
# speed limit
const MAX_SPEED = 6
const MIN_SPEED = 3
# speed change when pressing left or right
const ACCELERATION = 2
# 'up' force when pressing 'jump'
const JUMP_SPEED = 3
# 'up' force change to slow down the jump speed
const JUMP_DEACCELERATION = 4

enum PLAYER_STATE {
	default = 0,
	jump = 1
}

onready var wheel_front = get_node("WheelFront")
onready var wheel_center = get_node("WheelCenter")
onready var wheel_back = get_node("WheelBack")

var player_state = PLAYER_STATE.default
var on_ground = false
var cur_velocity = Vector2()


func _ready():
	set_fixed_process(true)
	cur_velocity.x = DEFAULT_SPEED
	player_state = PLAYER_STATE.default
	on_ground = false
	GameManager.current_player = self
	
	
func _draw():
	if wheel_front.is_colliding():
		draw_circle(wheel_front.get_collision_pos() - get_pos(), 10.0, Color(1.0,0,0))
		
	if wheel_center.is_colliding():
		draw_circle(wheel_center.get_collision_pos() - get_pos(), 10.0, Color(0,1.0,0))
	
	if wheel_back.is_colliding():
		draw_circle(wheel_back.get_collision_pos() - get_pos(), 10.0, Color(0,0,1.0))
	

func _fixed_process(delta):
	
	if player_state == PLAYER_STATE.jump:
		cur_velocity.y += delta * JUMP_DEACCELERATION	
	else:
		if Input.is_action_pressed("ui_right"):
			cur_velocity.x += ACCELERATION * delta
		if Input.is_action_pressed("ui_left"):
			cur_velocity.x -= ACCELERATION * delta
		if Input.is_action_pressed("ui_accept") and is_jump_allowed():
			player_state = PLAYER_STATE.jump
			cur_velocity.y = -JUMP_SPEED
			on_ground = false
	
	cur_velocity.x = clamp(cur_velocity.x, MIN_SPEED, MAX_SPEED)
	cur_velocity.y = clamp(cur_velocity.y, -JUMP_SPEED, JUMP_SPEED)
	set_pos(get_pos() + cur_velocity)
	
	update()


func is_jump_allowed():
	return player_state == PLAYER_STATE.default and on_ground