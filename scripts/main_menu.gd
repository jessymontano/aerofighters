extends Control

const SHIPS := [
	"res://assets/sprites/player/ship_1.png",
	"res://assets/sprites/player/ship_2.png",
	"res://assets/sprites/player/ship_3.png",
	"res://assets/sprites/player/ship_4.png",
]
const NAMES := ["Fighter I", "Fighter II", "Fighter III", "Fighter IV"]

const LEVEL_SCENES := [
	"res://scenes/game.tscn",
	"res://scenes/game_2.tscn",
]
const LEVEL_NAMES := ["LEVEL 1", "LEVEL 2"]

const UI_SOUNDS: Array[AudioStream] = [
	preload("res://assets/audio/back.ogg"),
	preload("res://assets/audio/cancel.ogg"),
	preload("res://assets/audio/select.ogg"),
	preload("res://assets/audio/start.ogg")
]
@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var selected: int = 0
var selected_level: int = 0

@onready var preview:    TextureRect = $VBox/ShipRow/Preview
@onready var ship_name:  Label       = $VBox/ShipName
@onready var level_lbl:  Label       = $VBox/LevelRow/LevelLabel

func _ready() -> void:
	GameManager.reset()
	_refresh()

func _refresh() -> void:
	var tex := load(SHIPS[selected]) as Texture2D
	if tex:
		preview.texture = tex
	ship_name.text = NAMES[selected]
	GameManager.selected_ship = selected
	level_lbl.text = LEVEL_NAMES[selected_level]

func _on_prev_pressed() -> void:
	player.stream = UI_SOUNDS[2]
	player.play()
	selected = (selected - 1 + SHIPS.size()) % SHIPS.size()
	_refresh()

func _on_next_pressed() -> void:
	player.stream = UI_SOUNDS[2]
	player.play()
	selected = (selected + 1) % SHIPS.size()
	_refresh()

func _on_level_prev_pressed() -> void:
	player.stream = UI_SOUNDS[2]
	player.play()
	selected_level = (selected_level - 1 + LEVEL_SCENES.size()) % LEVEL_SCENES.size()
	_refresh()

func _on_level_next_pressed() -> void:
	player.stream = UI_SOUNDS[2]
	player.play()
	selected_level = (selected_level + 1) % LEVEL_SCENES.size()
	_refresh()

func _on_start_pressed() -> void:
	player.stream = UI_SOUNDS[3]
	player.play()
	await get_tree().create_timer(0.4).timeout
	if selected_level == 1:
		GameManager.current_level = 2
	get_tree().change_scene_to_file(LEVEL_SCENES[selected_level])

func _on_quit_pressed() -> void:
	player.stream = UI_SOUNDS[1]
	player.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
