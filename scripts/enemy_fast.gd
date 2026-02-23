extends "res://scripts/enemy.gd"

# Enemigo rápido: baja en línea recta veloz con leve zigzag
var time: float = 0.0
var shoot_time: float = 0.0
@export var circle_bullets: int = 8
@export var circle_radius: float = 100.0

func _ready() -> void:
	hp = 1
	score_type = "fast"
	shoot_interval = 1.2
	super()
	time = randf() * TAU

func _physics_process(delta: float) -> void:
	time += delta
	shoot_time += delta
	
	velocity.y = 200.0
	velocity.x = sin(time * 3.5) * 45.0
	move_and_slide()

func shoot() -> void:
	if not bullet_scene:
		return
	
	for i in range(circle_bullets):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(0, 18)
		var angle = (2.0 * PI / circle_bullets) * i
		bullet.direction = Vector2(sin(angle), cos(angle))
		get_parent().add_child(bullet)
		
		if i == 0 and shoot_sfx:
			shoot_sfx.play()
