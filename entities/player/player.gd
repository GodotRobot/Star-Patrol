extends RigidBody2D

# player can't exceed MAX_SPEED going forward or MIN_SPEED going backwards
const MAX_SPEED = 200
const MIN_SPEED = 50

# the default movement vector, when the user isn't pressing left or right
const DEFAULT_VELOCITY = Vector2(100, 0)

# velocity factors for each direction, applied when the user presses left/right
const DIRECTION_VELOCITY_FACTOR = {
	FORWARD = Vector2(50, 0),
	BACKWARDS = Vector2(-50, 0),
	UP = Vector2(0, 1),
	DOWN = Vector2(0, -1)
}

# the current linear movement vector
var current_acceleration_velocity = Vector2()

func _ready():
	set_fixed_process(true)
	current_acceleration_velocity = DEFAULT_VELOCITY
	
func _fixed_process(delta):
	if Input.is_action_pressed("ui_right"):
		current_acceleration_velocity += (DIRECTION_VELOCITY_FACTOR.FORWARD * delta)
	elif Input.is_action_pressed("ui_left"):
		current_acceleration_velocity += (DIRECTION_VELOCITY_FACTOR.BACKWARDS * delta)
	
	# making sure the user isn't oer the speed limit
	clamp_speed()
	#print("speed =" + String(current_acceleration_velocity.x))

func _integrate_forces(state):
	# get the current linear velocity from the physics engine
	var cur_linear_velocity = state.get_linear_velocity()
	# clamp the x axis
	cur_linear_velocity.x = DEFAULT_VELOCITY.x
	# apply the modified linear velocity vector to the player
	state.set_linear_velocity(cur_linear_velocity + current_acceleration_velocity)
	
func clamp_speed():
	if current_acceleration_velocity.x > MAX_SPEED:
		current_acceleration_velocity.x = MAX_SPEED
	if current_acceleration_velocity.x < MIN_SPEED:
		current_acceleration_velocity.x = MIN_SPEED
