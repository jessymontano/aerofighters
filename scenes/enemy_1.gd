extends "res://scripts/enemy.gd"

@export var horizontal_amplitude: float = 100.0
@export var horizontal_speed: float = 2.0

var start_x: float
var time: float = 0.0

func _ready() -> void:
	super()
	start_x = position.x
	
func _physics_process(delta: float) -> void:
	time += delta
	
	velocity.y = SPEED
	
	velocity.x = cos(time * horizontal_speed) * horizontal_amplitude * delta * 60
	
	move_and_slide()
