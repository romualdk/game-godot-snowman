extends Spatial

var debug = OS.is_debug_build()

onready var snowball_scene = load("res://scenes/Snowball/Snowball.tscn")
onready var gui = get_node("GUI")

var picked = false
var picked_snowball
var balls = 0

func _ready():
	gui.setMusic(!debug)

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		process_click()
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(delta):
	pass

func process_click():
	var mousePos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * 1000
	
	var space_state = get_world().get_direct_space_state()
	var hit = space_state.intersect_ray(from, to, [self], 1)
	
	if hit.size() != 0:
		if hit.collider.is_in_group("snowballs") == true:
			pick(hit.collider, hit.position)
		elif picked == true:
			pick(hit.collider, hit.position)
		else:
			spawn(hit.position)
			balls += 1
			
			if balls == 1:
				var hand = get_node("SwipeCallToAction")
				hand.queue_free()

func spawn(position):
	var snowball = snowball_scene.instance()
	snowball.translation = position
	add_child(snowball)

func pick(snowball, position):
	if picked == false:
		picked = true
		picked_snowball = snowball
		picked_snowball.mode = RigidBody.MODE_STATIC
	else:
		var newPos = Vector3(position.x, position.y + 0.5, position.z)
		picked_snowball.translation = newPos
		picked_snowball.mode = RigidBody.MODE_RIGID
		picked_snowball.apply_central_impulse(Vector3.ZERO)
		picked = false
		picked_snowball = null
	
