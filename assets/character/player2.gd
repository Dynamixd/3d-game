extends CharacterBody3D

@export var base_speed = 5
@export var sprint_speed = 10
@export var jump_velocity = 4.5

@export var camera: Camera3D
@export var pivot: Node3D

@export var bullet: PackedScene
@export var bullet_velocity = 30
@export var Bullet_Point: Marker3D
var camera_collision = Get_Camera_Collision

var current_speed = base_speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * 0.002)
			camera.rotate_x(-event.relative.y * 0.002)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	# Handle sprinting
	if Input.is_action_just_pressed("sprint"):
		current_speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		current_speed = base_speed
	
	# Call the shoot() function on left mouse button
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
func shoot() -> void:
	# Get a raycast point from the center of the camera
	var camera_collision = Get_Camera_Collision()
	
	# Get direction from the raycast and the bullet_point marker
	var direction = (camera_collision - Bullet_Point.get_global_transform().origin).normalized()
	
	# Instantiate the bullet scene
	var projectile = bullet.instantiate()
	
	# Spawns the bullet at the Bullet_Point marker and gives it a velocity in the direction of the raycast
	get_parent().add_child(projectile)
	projectile.global_position = Bullet_Point.global_position
	projectile.set_linear_velocity(direction*bullet_velocity)
	
# Just a little mess around with ray casting, much easier way to do this is just set transform relative to bullet marker
# Can easily be used for hitscan bullets instead of projectile based bullets
func Get_Camera_Collision() -> Vector3:
	# Get viewport size and spawn ray from center of viewport
	var viewport = get_viewport().get_size()
	var ray_origin = camera.project_ray_origin(viewport/2)
	# Set max distance of ray if no collision detected
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2)*100
	# Find intersection of ray with 3d object
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	# Return either the collision point of the ray with 3d object or the maximum ray distance
	if not intersection.is_empty():
		var col_point = intersection.position
		return col_point
	else:
		return ray_end
		
