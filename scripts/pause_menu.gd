extends CanvasLayer

const UI_SOUNDS: Array[AudioStream] = [
	preload("res://assets/audio/back.ogg"),
	preload("res://assets/audio/cancel.ogg"),
	preload("res://assets/audio/select.ogg"),
	preload("res://assets/audio/start.ogg")
]
@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			_pause()


func _pause() -> void:
	player.stream = UI_SOUNDS[1]
	player.play()
	show()
	get_tree().paused = true


func _resume() -> void:
	hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	player.stream = UI_SOUNDS[3]
	player.play()
	_resume()


func _on_menu_pressed() -> void:
	player.stream = UI_SOUNDS[0]
	player.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	player.stream = UI_SOUNDS[1]
	player.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = false
	get_tree().quit()
