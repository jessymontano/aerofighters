extends AnimatedSprite2D

func _ready() -> void:
	# Al terminar la animación se elimina sola
	animation_finished.connect(queue_free)
