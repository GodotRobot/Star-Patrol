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
# once the player hit the finish line, allow it to advance for this amount of time (sec) until the level is finished
const POST_FINISH_LINE_DELAY = 4
# delay between bullets fire in seconds
const BULLET_RECOVERY_DELAY_MSEC = 200
const BULLET_SPEED = 700

enum PLAYER_STATE {
	default = 0,        # default player state, moving to the right
	jump = 1,           # player is currently jumping
	death_anim = 2,     # player hit a 'death' tile and death animation is running
	killed = 3,         # death animation is over, player is dead
	finish_line = 4,    # player reached the finish line, used to mark the end of the level
	end_of_level = 5    # player moved beyond the right side of the screen after crossing the finish line
}

onready var bullet = preload("res://entities/bullets/player_bullet.tscn")

onready var wheel_front = get_node("WheelFront")
onready var wheel_center = get_node("WheelCenter")
onready var wheel_back = get_node("WheelBack")
onready var wheels_array = [wheel_front, wheel_center, wheel_back]

onready var death_anim = get_node("DeathAnimation")
onready var gun = get_node("Gun")

var player_state = PLAYER_STATE.default
var cur_velocity = Vector2()
var jump_slowdown_factor = 0
var post_finish_line_delay_counter = 0
var bullet_last_timestamp = 0

func _ready():
	set_fixed_process(true)
	GameManager.current_player = self
	activate()

func activate():
	player_state = PLAYER_STATE.default
	get_node("Camera2D").make_current()
	get_node("Sprite").show()
	gun.reset()
	for wheel in wheels_array:
		wheel.show()
	set_rot(0)
	cur_velocity = Vector2(DEFAULT_SPEED, 0)

func _fixed_process(delta):
	if player_state == PLAYER_STATE.death_anim or player_state == PLAYER_STATE.end_of_level:
		return
	if player_state == PLAYER_STATE.finish_line:
		update_finish_line(delta)
	if player_state == PLAYER_STATE.jump:
		update_jump(delta)
	else:
		if Input.is_action_pressed("ui_right"):
			cur_velocity.x += ACCELERATION
		if Input.is_action_pressed("ui_left"):
			cur_velocity.x -= ACCELERATION
		if Input.is_action_pressed("ui_accept") and is_jump_allowed():
			jump()
		if Input.is_action_pressed("fire") and is_fire_allowed():
			fire()
	
	if Input.is_action_pressed("ui_up"):
		gun.raise()
	if Input.is_action_pressed("ui_down"):
		gun.lower()

	# keep the velocity at a fixed range
	cur_velocity.x = clamp(cur_velocity.x, MIN_SPEED, MAX_SPEED)
	cur_velocity.y = clamp(cur_velocity.y, -JUMP_SPEED, JUMP_SPEED)
	
	update_wheels() # update wheels rotation speed and position
	update_vehicle(delta) # move the vehicle and keep the vehicle above the wheels

func update_finish_line(delta):
	# count the time to the end of the level passed the finish line
	post_finish_line_delay_counter += delta
	if post_finish_line_delay_counter > POST_FINISH_LINE_DELAY:
		player_state = PLAYER_STATE.end_of_level
	# if player reached the finish line mid-jump, continue updating the jump back down
	if not is_touching_ground():
		update_jump(delta)

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

func kill():
	player_state = PLAYER_STATE.death_anim
	get_node("Sprite").hide()
	gun.hide()
	for wheel in wheels_array:
		wheel.hide()
	death_anim.set_frame(0)
	death_anim.show()
	death_anim.play("Death")

func _on_Player_body_enter(body):
	# if the player is passed the finish line, ignore collision with death tiles
	if player_state == PLAYER_STATE.finish_line:
		return
	
	var groups = body.get_groups()
	if groups.has("death"):
		# player died by hitting a 'death' tile
		kill()
	elif groups.has("finish"):
		# player touched the 'finish' area, clear camera so the player will disappear to the right
		get_node("Camera2D").clear_current()
		player_state = PLAYER_STATE.finish_line
		post_finish_line_delay_counter = 0

func fire():
	bullet_last_timestamp = OS.get_ticks_msec()
	var new_bullet = bullet.instance()
	var position = Vector2() 
	position =  get_global_pos() + gun.get_offset()
	var velocity = Vector2()
	if gun.is_raised():
		# keep the bullet moving with the player along the x axis when the gun is raised
		velocity = Vector2(cur_velocity.x, -BULLET_SPEED)
	else:
		velocity = Vector2(BULLET_SPEED, 0)
	new_bullet.init(position, velocity)
	get_parent().add_child(new_bullet)

func is_fire_allowed():
	# player can fire a bullet if the gun is not mid-animation and enough time passed since the last bullet was fired
	var cur_timestamp = OS.get_ticks_msec()
	return gun.is_animation_finished() and cur_timestamp - bullet_last_timestamp > BULLET_RECOVERY_DELAY_MSEC

func _on_DeathAnimation_finished():
	death_anim.hide()
	player_state = PLAYER_STATE.killed

func is_killed():
	return player_state == PLAYER_STATE.killed

func is_reached_end_of_level():
	return player_state == PLAYER_STATE.end_of_level
