extends RigidBody2D

# starting speed
const DEFAULT_SPEED = 3200
# speed limit
const MAX_SPEED = 8000
const MIN_SPEED = 2800
# speed change when pressing left or right
const ACCELERATION = 4000
# 'up' force when pressing 'jump'
const JUMP_SPEED = 8000
# 'up' force change to slow down the jump speed
const JUMP_DEACCELERATION = 20000

enum PLAYER_STATE {
	default = 0,
	jump = 1
}

var player_state = PLAYER_STATE.default
var on_ground = false
var cur_velocity = Vector2()


func _ready():
	set_fixed_process(true)
	cur_velocity.x = DEFAULT_SPEED
	set_applied_force(cur_velocity)
	player_state = PLAYER_STATE.default
	on_ground = false


func _fixed_process(delta):
	var change_velocity = false
	if player_state == PLAYER_STATE.jump:
		cur_velocity.y += delta * JUMP_DEACCELERATION
		change_velocity = true
	else:
		if Input.is_action_pressed("ui_right"):
			cur_velocity.x += ACCELERATION * delta
			change_velocity = true
			
		if Input.is_action_pressed("ui_left"):
			cur_velocity.x -= ACCELERATION * delta
			change_velocity = true
			
		if Input.is_action_pressed("ui_accept") and is_jump_allowed():
			player_state = PLAYER_STATE.jump
			cur_velocity.y = -JUMP_SPEED
			on_ground = false
			change_velocity = true
			
	if change_velocity:
		# making sure the player is not over the speed limit
		cur_velocity.x = clamp(cur_velocity.x, MIN_SPEED, MAX_SPEED)
		cur_velocity.y = clamp(cur_velocity.y, -JUMP_SPEED, JUMP_SPEED)
		set_applied_force(cur_velocity)


func is_jump_allowed():
	return player_state == PLAYER_STATE.default && on_ground


func _on_GroundHitCheck_body_enter(body):
	var groups = body.get_groups()
	if groups.has("ground"):
		# player touched the ground following a jump
		on_ground = true
		player_state = PLAYER_STATE.default
		cur_velocity.y = 0
		set_applied_force(cur_velocity)
