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

# distance of the wheel from the vehicle on the y axis
const vehicle_wheel_offset = 20

enum PLAYER_STATE {
	default = 0,
	jump = 1,
	death = 2
}

onready var wheel_front = get_node("WheelFront")
onready var wheel_center = get_node("WheelCenter")
onready var wheel_back = get_node("WheelBack")
onready var wheels_array = [wheel_front, wheel_center, wheel_back]

var player_state = PLAYER_STATE.default
var cur_velocity = Vector2()


func _ready():
	set_fixed_process(true)
	cur_velocity.x = DEFAULT_SPEED
	player_state = PLAYER_STATE.default
	GameManager.current_player = self
	
	
func _fixed_process(delta):
	if player_state == PLAYER_STATE.jump:
		cur_velocity.y += delta * JUMP_DEACCELERATION	
		if is_touching_ground():
			player_state = PLAYER_STATE.default
	else:
		if Input.is_action_pressed("ui_right"):
			cur_velocity.x += ACCELERATION * delta
		if Input.is_action_pressed("ui_left"):
			cur_velocity.x -= ACCELERATION * delta
		if Input.is_action_pressed("ui_accept") and is_jump_allowed():
			jump()
	
	cur_velocity.x = clamp(cur_velocity.x, MIN_SPEED, MAX_SPEED)
	cur_velocity.y = clamp(cur_velocity.y, -JUMP_SPEED, JUMP_SPEED)
	
	update_wheels_pos()
	update_vehicle_pos()


func is_jump_allowed():
	return player_state == PLAYER_STATE.default
	
func jump():
	player_state = PLAYER_STATE.jump
	cur_velocity.y = -JUMP_SPEED
	for wheel in wheels_array:
		wheel.reset_ground_col_check()
	
func update_vehicle_pos():
	set_pos(get_pos() + cur_velocity)
	
	if player_state == PLAYER_STATE.default:
		var new_pos = get_pos()
		# use the center wheel to position the vehicle above the wheels
		new_pos.y += wheel_center.get_pos().y - vehicle_wheel_offset
		set_pos(new_pos)
	
		# reset and rotate the vehicle to match the two outer wheels ground collision points
		set_rot(0)
		var horizontal = Vector2(100,0)
		var player_vector = wheel_front.get_colliding_position() - wheel_back.get_colliding_position()
		var angle = horizontal.angle_to(player_vector)
		set_rot(angle)
	
func update_wheels_pos():
	for wheel in wheels_array:
		if wheel.is_on_ground():
			wheel.set_pos(wheel.get_colliding_position())

func is_touching_ground():
	var ground_contact = 0
	for wheel in wheels_array:
		if wheel.is_on_ground():
			ground_contact += 1
	
	# we assume the vehicle tocuhes the ground of all wheels do
	return ground_contact == wheels_array.size()


func _on_Player_body_enter( body ):
	var groups = body.get_groups()
	if groups.has("death"):
		print("death")
