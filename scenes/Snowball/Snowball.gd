extends RigidBody

const SPEED = 1
const GROWTH = 0.001
const MIN_SIZE = 0.05
const MAX_SIZE = 0.75

var size = MIN_SIZE
var should_move = false

var last_position = Vector3()
var travelled_distance = 0

var target = Vector3()

var collision_shape
var mesh_instance

var base_material
var color

func set_base_material():
	mesh_instance.set_surface_material(0, base_material)

func change_color(new_color):
	color = new_color
	
	if mesh_instance:
		if color:
			var new_material = base_material.duplicate()
			new_material.albedo_color = color
			mesh_instance.set_surface_material(0, new_material)
		else:
			mesh_instance.set_surface_material(0, base_material)

func _ready():
	collision_shape = get_node("CollisionShape")
	mesh_instance = get_node("MeshInstance")
	base_material = mesh_instance.get_surface_material(0)
	setLastPosition()
	
	

func setLastPosition() :
	last_position = self.to_global(self.translation)

func _process(delta):
	if should_move == true:
		set_target()
		grow()
		setLastPosition()
	
	# if Input.is_action_just_released("click"):
	# 	self.should_move = false

func set_target():
	var mousePos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera()
	
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * 1000
	
	var spaceState = get_world().get_direct_space_state()
	var result = spaceState.intersect_ray(from, to, [self], 1)
	
	if "position" in result:
		target = result.position

func grow():
	var current_position = self.to_global(self.translation)
	var last_position_2d = Vector2(last_position.x, last_position.y)
	var current_position_2d = Vector2(current_position.x, current_position.y)
	travelled_distance += last_position_2d.distance_to(current_position_2d)
	
	size = travelled_distance * GROWTH
	
	if size < MIN_SIZE:
		size = MIN_SIZE
	elif size > MAX_SIZE:
		size = MAX_SIZE

func resize():
	collision_shape.shape.radius = size
	mesh_instance.scale = Vector3(size, size, size)

func look_follow(state, current_transform, target_position):
	var target_dir = (target_position - current_transform.origin).normalized()
	target_dir.y = 0
	
	if should_move == true:
		state.set_linear_velocity(target_dir * SPEED)

func _integrate_forces(state):
	resize()
	look_follow(state, get_global_transform(), target)
