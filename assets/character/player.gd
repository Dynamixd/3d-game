extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 75
@export var jump_height = 30
@export var camera : Camera3D
@export var character : CharacterBody3D
@export var look_sens = 50

var look_dir: Vector2
var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("back"):
		direction.z += 1
	if Input.is_action_pressed("left"):
		direction.x += 1
	if Input.is_action_pressed("right"):
		direction.x -= 1
	if Input.is_action_pressed("jump"):
		jump()
	
	_gravity(delta)
	_rotate_camera(delta)
	
	direction = direction.normalized()
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	velocity = target_velocity
	move_and_slide()

func jump() -> void:
	target_velocity.y = jump_height

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	
func _rotate_camera(delta: float):
	var input = Input.get_vector("look_right", "look_left", "look_up", "look_down")
	look_dir += input
	rotation.y -= look_dir.x * look_sens * delta
	character.rotation.x = clamp(character.rotation.x - look_dir.y * look_sens * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _gravity(delta: float) -> void:
		if not is_on_floor():
			target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
