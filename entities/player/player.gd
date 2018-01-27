extends RigidBody2D

# player can't exceed MAX_SPEED going forward or MIN_SPEED going backwards
const MAX_SPEED = 200
const MIN_SPEED = 50

# how long will the player stay in jump mode
const JUMP_DELAY = 0.17

# the default starting movement vector
const DEFAULT_VELOCITY = Vector2(100, 0)

# velocity factors for each direction, applied when the user presses left/right
const DIRECTION_VELOCITY_FACTOR = {
	FORWARD = Vector2(80, 0),
	BACKWARDS = Vector2(-80, 0),
	UP = Vector2(0, -20),
	DOWN = Vector2(0, 20),
}

enum PLAYER_STATE {
	default = 0,
	jump = 1
}

# the current movement acceleration vector
var current_acceleration_velocity = Vector2()
var jump_delay_counter = 0
var on_ground = false
var player_state = PLAYER_STATE.default


func _ready():
	set_fixed_process(true)
	current_acceleration_velocity = DEFAULT_VELOCITY
	player_state = PLAYER_STATE.default
	on_ground = false
	
func _fixed_process(delta):
	if player_state == PLAYER_STATE.jump:
		update_jump(delta)
	else:
		# forward and backwards velocity change
		if Input.is_action_pressed("ui_right"):
			current_acceleration_velocity += (DIRECTION_VELOCITY_FACTOR.FORWARD * delta)
		elif Input.is_action_pressed("ui_left"):
			current_acceleration_velocity += (DIRECTION_VELOCITY_FACTOR.BACKWARDS * delta)
		
		if Input.is_action_pressed("ui_select") and is_jump_allowed():
			jump()
		
		# making sure the user isn't oer the speed limit
		if current_acceleration_velocity.x > MAX_SPEED:
			current_acceleration_velocity.x = MAX_SPEED
		if current_acceleration_velocity.x < MIN_SPEED:
			current_acceleration_velocity.x = MIN_SPEED


func _integrate_forces(state):
	# get the current linear velocity from the physics engine
	var cur_linear_velocity = state.get_linear_velocity()
	# clamp the x axis
	cur_linear_velocity.x = DEFAULT_VELOCITY.x
	# apply the modified linear velocity vector to the player
	state.set_linear_velocity(cur_linear_velocity + current_acceleration_velocity)


func jump():
	current_acceleration_velocity += DIRECTION_VELOCITY_FACTOR.UP
	jump_delay_counter = 0
	player_state = PLAYER_STATE.jump	


func is_jump_allowed():
	# allow jump when the player is on the ground and not currently jumping
	return on_ground and player_state != PLAYER_STATE.jump
	
	
func update_jump(delta):
	jump_delay_counter += delta
	if jump_delay_counter > JUMP_DELAY:
		# kill jump velocity
		current_acceleration_velocity.y = 0
		player_state = PLAYER_STATE.default


func _on_GroundHitCheck_body_enter(body):
	var groups = body.get_groups()
	if groups.has("ground"):
		on_ground = true


func _on_GroundHitCheck_body_exit(body):
	var groups = body.get_groups()
	if groups.has("ground"):
		on_ground = false
