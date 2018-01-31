# http://docs.godotengine.org/en/stable/learning/step_by_step/singletons_autoload.html

extends Node

# the currently active scene
var current_scene = null
	
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# Immediately free the current scene,
	# there is no risk here.
	if current_scene:
		current_scene.free()
	# Load new scene
	var s = null
	if path != null:
		s = ResourceLoader.load(path)
	if not s:
		# level not found - print error and do nothing
		print("can't find scene ", path)
		return
		
	# Instance the new scene
	current_scene = s.instance()
	# Add it to the active scene, as child of root
	GameManager.add_child(current_scene)
	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene(current_scene)
	