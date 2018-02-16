extends Area2D

# starting speed, pixels/sec
const DEFAULT_SPEED = 100
# speed limit
const MAX_SPEED = 250
const MIN_SPEED = 100
# speed change when pressing left or right
const ACCELERATION = 2
# 'up' force when pressing 'jump'
const JUMP_SPEED = 250
# 'up' force change to slow down the jump speed
const JUMP_DEACCELERATION = 10
# how fast will the vehicle rotate to 0 degrees after a jump
const ROT_RESET_SPEED = 3

# distance of the wheel from the vehicle on the y axis
const VEHICLE_TO_WHEEL_OFFSET = 20

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
var jump_slowdown_factor = 0


func _ready():
	set_fixed_process(true)
	cur_velocity.x = DEFAULT_SPEED
	player_state = PLAYER_STATE.default
	GameManager.current_player = self
	
	
func _fixed_process(delta):
	if player_state == PLAYER_STATE.jump:
		update_jump(delta)
	else:
		if Input.is_action_pressed("ui_right"):
			cur_velocity.x += ACCELERATION
		if Input.is_action_pressed("ui_left"):
			cur_velocity.x -= ACCELERATION
		if Input.is_action_pressed("ui_accept") and is_jump_allowed():
			jump()

	# keep the velocity at a fixed range
	cur_velocity.x = clamp(cur_velocity.x, MIN_SPEED, MAX_SPEED)
	cur_velocity.y = clamp(cur_velocity.y, -JUMP_SPEED, JUMP_SPEED)
	
	update_wheels() # update wheels rotation speed and position
	update_vehicle(delta) # move the vehicle and keep the vehicle above the wheels

func is_jump_allowed():
	return player_state == PLAYER_STATE.default
	
func jump():
	# enter jump mode, add initial jump speed
	player_state = PLAYER_STATE.jump
	cur_velocity.y -= JUMP_SPEED
	# during the jump, the player starts to slow down and head back down
	jump_slowdown_factor = 0
	# let the wheels know we are no longer on the ground
	for wheel in wheels_array:
		wheel.reset_ground_col_check()

func update_jump(delta):
	# add the slowdown factor for the jump so it would appear more realistic
	jump_slowdown_factor += delta * JUMP_DEACCELERATION
	cur_velocity.y += jump_slowdown_factor
	
	# revert vehicle rotation during the jump
	var new_angle = lerp(get_rot(), 0.0, delta * ROT_RESET_SPEED)
	set_rot(new_angle)
	
	if is_touching_ground():
		# player landed after a jump
		cur_velocity.y = 0
		set_rot(0)
		player_state = PLAYER_STATE.default
	
func update_vehicle(delta):
	var new_pos = get_pos() + (cur_velocity * delta)
	# use the center wheel to position the vehicle above the wheels
	new_pos.y += wheel_center.get_pos().y - VEHICLE_TO_WHEEL_OFFSET
	set_pos(new_pos)
	
	if player_state == PLAYER_STATE.default:
		# rotate the vehicle to match the two outer wheels ground collision points
		set_rot(0)
		var horizontal = Vector2(1,0)
		var player_vector = wheel_front.get_colliding_position() - wheel_back.get_colliding_position()
		var angle = horizontal.angle_to(player_vector)
		set_rot(angle)
	
func update_wheels():
	for wheel in wheels_array:
		if wheel.is_on_ground():
			# keep the wheel on the ground tiles
			wheel.set_pos(wheel.get_colliding_position())
		if player_state == PLAYER_STATE.default:
			# change the wheels rotation based on current speed
			var speed_factor = cur_velocity.x / DEFAULT_SPEED
			wheel.set_rotation_speed(speed_factor)

func is_touching_ground():
	var ground_contact = 0
	for wheel in wheels_array:
		if wheel.is_on_ground():
			ground_contact += 1
	
	# we assume the vehicle touches the ground if at least 1 wheel does
	return ground_contact >= 1

func _on_Player_body_enter(body):
	var groups = body.get_groups()
	if groups.has("death"):
		# TODO: add death logic
		print("death")
