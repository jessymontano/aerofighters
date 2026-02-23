extends Control

@onready var title_lbl: Label = $VBox/Title
@onready var score_lbl: Label = $VBox/ScoreLabel

const UI_SOUNDS: Array[AudioStream] = [
	preload("res://assets/audio/back.ogg"),
	preload("res://assets/audio/cancel.ogg"),
	preload("res://assets/audio/select.ogg"),
	preload("res://assets/audio/start.ogg"),
	preload("res://assets/audio/gameover.ogg"),
	preload("res://assets/audio/win.ogg")
]
@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Asegurarse de que el árbol no esté pausado al llegar aquí
	get_tree().paused = false

	score_lbl.text = "SCORE   %07d" % GameManager.score

	if GameManager.current_level >= 99:
		player.stream = UI_SOUNDS[4]
		player.play()
		title_lbl.text = "YOU WIN!"
		title_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	else:
		player.stream = UI_SOUNDS[5]
		player.play()
		title_lbl.text = "GAME OVER"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))


func _on_retry_pressed() -> void:
	player.stream = UI_SOUNDS[3]
	player.play()
	await get_tree().create_timer(0.4).timeout
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu_pressed() -> void:
	player.stream = UI_SOUNDS[0]
	player.play()
	await get_tree().create_timer(0.3).timeout
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
