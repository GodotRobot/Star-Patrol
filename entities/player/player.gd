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

var player_state = PLAYER_STATE.default
var on_ground = false
var cur_velocity = Vector2()


func _ready():
	set_fixed_process(true)
	cur_velocity.x = DEFAULT_SPEED
	player_state = PLAYER_STATE.default
	on_ground = false


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


func is_jump_allowed():
	return player_state == PLAYER_STATE.default and on_ground


func _on_HitCheck_body_enter( body ):
	var groups = body.get_groups()
	if groups.has("ground"):
		# player touched the ground following a jump
		on_ground = true
		player_state = PLAYER_STATE.default
		cur_velocity.y = 0
