extends CharacterBody3D

@export var base_speed = 5
@export var sprint_speed = 10
@export var jump_velocity = 6
@export var MOUSE_SENSITIVITY : float = 1.0
@export var player : CharacterBody3D

@export var acceleration : float = 0.1
@export var deceleration : float = 0.1

@export var camera: Camera3D

@export var TILT_LOWER_LIMIT : float = -90.0
@export var TILT_UPPER_LIMIT : float = 90.0

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var current_speed = base_speed

func _ready():
	
	Global.player = self

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	#	player.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
	#	camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
	#	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(TILT_LOWER_LIMIT), deg_to_rad(TILT_UPPER_LIMIT))
func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, deg_to_rad(TILT_LOWER_LIMIT), deg_to_rad(TILT_UPPER_LIMIT))
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	camera.transform.basis = Basis.from_euler(_camera_rotation)
	camera.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
		
	_update_camera(delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	# Handle sprinting
	if Input.is_action_just_pressed("sprint"):
		current_speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		current_speed = base_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x,direction.x * current_speed, acceleration)
		velocity.z = lerp(velocity.z,direction.z * current_speed, acceleration)
	else:
		#velocity.x = move_toward(velocity.x, 0, deceleration)
		#velocity.z = move_toward(velocity.z, 0, deceleration)
		velocity.x = lerp(velocity.x,direction.x * current_speed, deceleration)
		velocity.z = lerp(velocity.z,direction.z * current_speed, deceleration)
#		velocity.x = 0.0
#		velocity.z = 0.0
	
	move_and_slide()
