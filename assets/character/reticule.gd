extends CenterContainer

@export var RETICULE_LINES : Array[Line2D]
@export var PLAYER_CONTROLLER : CharacterBody3D
@export var RETICULE_SPEED : float = 0.25
@export var RETICULE_DISTANCE : float = 2.0
@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_reticule_lines()

func _draw():
	draw_circle(Vector2(0,0),DOT_RADIUS,DOT_COLOR)
	
func adjust_reticule_lines():
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	var origin = Vector3.ZERO
	var pos = Vector2.ZERO
	var speed = origin.distance_to(vel)
	
	RETICULE_LINES[0].position = lerp(RETICULE_LINES[0].position, pos + Vector2(0, -speed * RETICULE_DISTANCE), RETICULE_SPEED)
	RETICULE_LINES[1].position = lerp(RETICULE_LINES[1].position, pos + Vector2(speed * RETICULE_DISTANCE, 0), RETICULE_SPEED)
	RETICULE_LINES[2].position = lerp(RETICULE_LINES[2].position, pos + Vector2(0, speed * RETICULE_DISTANCE), RETICULE_SPEED)
	RETICULE_LINES[3].position = lerp(RETICULE_LINES[3].position, pos + Vector2(-speed * RETICULE_DISTANCE, 0), RETICULE_SPEED)
