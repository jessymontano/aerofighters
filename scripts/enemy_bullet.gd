extends Area2D

@export var speed: int = 280
var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# Detectar colisión con el jugador (layer 1)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
