extends Area2D

export (bool) var hole_bullet = false

onready var sprite = get_node("Sprite")
onready var animated_sprite = get_node("AnimatedSprite")

onready var hole_bullet_scene = preload("res://entities/bullets/hole_bullet.tscn")

const SPEED = 30.0 # movement speed
const MAX_DIST = 700.0 # follow the player for this maximum distance before leaving / kamikazing

# on this frame the death animation switches to explosion
const EXPLOSION_START_FRAME_NUM = 30

enum ENEMY_STATE {
	disabled,
	ready,
	active
}

var enemy_state = ENEMY_STATE.disabled
var dir = Vector2()
var original_global_transform = Matrix32()
var hole_bullet_fired = false

func disable():
	sprite.hide()
	animated_sprite.hide()
	set_collision_mask(0)
	set_layer_mask(0)
	enemy_state = ENEMY_STATE.disabled
	set_global_transform(original_global_transform)
	
func enable():
	set_collision_mask(2) # player bullets are on layer 2
	set_layer_mask(1)
	# enter from behind, same height (y)
	var r = original_global_transform.o
	var vps = get_viewport_rect().size
	set_pos(Vector2(r.x-vps.x/2, get_pos().y))
	dir = Vector2(SPEED * 20.0, 1.0)
	sprite.show()
	enemy_state = ENEMY_STATE.active
	print("activating enemy1: " + get_name())
	
func _ready():
	original_global_transform = get_global_transform()
	disable()
	set_fixed_process(true)

func is_flight_finished():
	if enemy_state == ENEMY_STATE.active:
		var vps = get_viewport_rect().size
		var player = GameManager.current_player
		# check if the enemy is gone to the right side of the viewport
		if get_pos().x > player.get_pos().x + vps.x:
			return true
	return false

func update_state():
	var player = GameManager.current_player
	if !player:
		return false

	# check if the enemy flew away without getting hit
	if is_flight_finished():
		disable()
	# check if the enemy is ready to be activated: it's in disable mode and in front of the player
	elif enemy_state == ENEMY_STATE.disabled and get_pos().x > player.get_pos().x:
		enemy_state = ENEMY_STATE.ready
	# enemy is ready and the player passed it, enemy will be activated
	elif enemy_state == ENEMY_STATE.ready and get_pos().x < player.get_pos().x:
		enable()

func is_hole_bullet_ready():
	if enemy_state != ENEMY_STATE.active or hole_bullet_fired:
		return false

	var player = GameManager.current_player
	var vps = get_viewport_rect().size
	# check if the enemy is close enough to the right side of the viewport
	if get_pos().x > player.get_pos().x + (vps.x/2) - 200:
		return true
	return false

func fire_hole_bullet():
	var hole_bullet = hole_bullet_scene.instance()
	var player = GameManager.current_player
	hole_bullet.set_velocity(-player.get_cur_velocity().x, 300)
	add_child(hole_bullet)
	hole_bullet_fired = true

func _fixed_process(delta):
	update_state()
	if enemy_state == ENEMY_STATE.active:
		update_flight(delta)
	
	if hole_bullet and is_hole_bullet_ready():
		fire_hole_bullet()

func update_flight(delta):
	# do a figure of 8	
	#var r = get_viewport_transform()
	#var vps = get_viewport_rect().size
	#print('r: ', r, ', vps: ', vps)
	#if r.x < 0.2 * vps.x || r.x > 0.8 * vps.x:
	#	dir.x = -dir.x
	#if r.y < 0.1 * vps.y || r.y > 0.3 * vps.y:
	#	dir.y = -dir.y
	translate(delta * dir)

func _on_Enemy1_area_enter(area):
	var groups = area.get_groups()
	if groups.has("player_bullet"):
		# enemy hit by a player bullet, remove the bullet and start the 'hit' sequence
		area.disable()
		on_enemy_hit()

func on_enemy_hit():
	# play the death animation and turn off collision check
	animated_sprite.set_frame(0)
	animated_sprite.show()
	animated_sprite.play("Death")
	set_collision_mask(0)

func _on_AnimatedSprite_frame_changed():
	# the death animation has 2 parts, hide the enemy when the explosion part of the animation starts
	if animated_sprite.is_playing() and animated_sprite.get_frame() == EXPLOSION_START_FRAME_NUM:
		sprite.hide()

func _on_AnimatedSprite_finished():
	# enemy death animation is finished
	disable()
