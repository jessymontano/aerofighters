extends "res://scripts/enemy.gd"

# Enemigo tipo 1: entra en diagonal y luego hace zigzag senoidal
@export var horizontal_amplitude: float = 75.0
@export var horizontal_speed: float = 2.4

var time: float = 0.0
var entry_done: bool = false
var entry_target_y: float = 100.0
# Dirección de entrada aleatoria: -1 desde izquierda, 1 desde derecha
var entry_dir: float = 1.0

func _ready() -> void:
	super()
	entry_dir = 1.0 if randf() > 0.5 else -1.0
	# Offset horizontal inicial para que no todos entren igual
	time = randf() * TAU

func _physics_process(delta: float) -> void:
	if not entry_done:
		# Entrada diagonal
		velocity.y = SPEED * 1.2
		velocity.x = entry_dir * SPEED * 0.5
		move_and_slide()
		if position.y >= entry_target_y:
			entry_done = true
	else:
		time += delta
		velocity.y = SPEED * 0.6
		velocity.x = cos(time * horizontal_speed) * horizontal_amplitude
		move_and_slide()
