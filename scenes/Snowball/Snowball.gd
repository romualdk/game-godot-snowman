extends RigidBody

const SPEED = 1
const GROWTH = 0.001
const MIN_SIZE = 0.05
const MAX_SIZE = 0.75

var size = MIN_SIZE
var should_move = true

var lastPosition = Vector3()
var travelledDistance = 0

var target = Vector3()

var collisionShape
var meshInstance

func _ready():
	collisionShape = get_node("CollisionShape")
	meshInstance = get_node("MeshInstance")
	setLastPosition()

func setLastPosition() :
	lastPosition = self.to_global(self.translation)

func _process(delta):
	if should_move == true:
		set_target()
		grow()
		setLastPosition()
	
	if Input.is_action_just_released("click"):
		should_move = false

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
	var currentPosition = self.to_global(self.translation)
	var lastPos2D = Vector2(lastPosition.x, lastPosition.y)
	var currentPos2D = Vector2(currentPosition.x, currentPosition.y)
	travelledDistance += lastPos2D.distance_to(currentPos2D)
	
	size = travelledDistance * GROWTH
	
	if size < MIN_SIZE:
		size = MIN_SIZE
	elif size > MAX_SIZE:
		size = MAX_SIZE

func resize():
	collisionShape.shape.radius = size
	meshInstance.scale = Vector3(size, size, size)

func look_follow(state, current_transform, target_position):
	var target_dir = (target_position - current_transform.origin).normalized()
	target_dir.y = 0
	
	if should_move:
		state.set_linear_velocity(target_dir * SPEED)

func _integrate_forces(state):
	resize()
	look_follow(state, get_global_transform(), target)
