extends Area2D

@export var speed: float = 80.0
@export var pickup_type: String = "health"
@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _time: float = 0.0
var _collected: bool = false

func _ready() -> void:
	_time = randf() * TAU
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_time += delta
	position.y += speed * delta
	position.x += sin(_time * 3.0) * 0.4
	if position.y > 720:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if body.is_in_group("player"):
		_collected = true
		player.reparent(get_tree().current_scene)
		player.global_position = global_position
		player.play()
		if pickup_type == "health":
			GameManager.gain_life()
		elif pickup_type == "power" and body.has_method("activate_powerup"):
			body.activate_powerup()
		queue_free()
