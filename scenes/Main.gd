extends Spatial

var debug = OS.is_debug_build()

onready var snowball_scene = load("res://scenes/Snowball/Snowball.tscn")
onready var gui = get_node("GUI")

var snowball = null

func _ready():
	gui.setMusic(!debug)
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	
func _input(event):
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		on_click()
	
	if event is InputEventMouseButton and event.is_action_released("click"):
		if snowball:
			set_snowball(null)
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func set_snowball(new_snowball):
	if snowball:
		if debug:
			snowball.set_base_material()
		
		snowball.should_move = false
		snowball = false
	
	if new_snowball:
		snowball = new_snowball
		snowball.should_move = true
		snowball.apply_central_impulse(Vector3(0.1, 0, 0))
		
		if debug:
			snowball.change_color(Color(1, 0, 0))

func hide_swipe_call_to_action():
	var hand = get_node("SwipeCallToAction")
	if hand:
		hand.queue_free()

func on_click():
	hide_swipe_call_to_action()
	
	var hit = raycast()
	if hit.size() != 0:
		# snowball
		if hit.collider.is_in_group("snowballs") == true:
			set_snowball(hit.collider)
		# ground
		else:
			spawn(hit.position)

func raycast():
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000
	
	var space_state = get_world().get_direct_space_state()
	var hit = space_state.intersect_ray(from, to, [self], 1)
	
	return hit

func spawn(position):
	var new_snowball = snowball_scene.instance()
	new_snowball.translation = position
	add_child(new_snowball)
	
	set_snowball(new_snowball)
	
