extends Node2D

@export var level_number: int = 1

@onready var spawner = $World/EnemySpawner
@onready var player  = $World/Player/player
@onready var music = $AudioStreamPlayer2D

var _ending := false


func _ready() -> void:
	music.play()
	# Resetear el juego solo al empezar desde el nivel 1 limpiamente
	if level_number == 1 and GameManager.current_level <= 1:
		GameManager.reset()

	GameManager.current_level = level_number

	spawner.boss_dead.connect(_on_level_complete)

	# Esperamos un frame para que el nodo del jugador esté listo
	await get_tree().process_frame
	if is_instance_valid(player):
		player.died.connect(_on_player_died)

	spawner.start_level(level_number)


func _on_level_complete() -> void:
	if _ending:
		return
	_ending = true
	GameManager.current_level = 99  # indica victoria

	# Usamos un Timer propio para no depender de get_tree() después del cambio de escena
	var t := Timer.new()
	t.one_shot  = true
	t.wait_time = 2.0
	add_child(t)
	t.start()
	await t.timeout
	if is_inside_tree():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_player_died() -> void:
	if _ending:
		return
	_ending = true

	var t := Timer.new()
	t.one_shot  = true
	t.wait_time = 1.4
	add_child(t)
	t.start()
	await t.timeout
	if not is_inside_tree():
		return

	get_tree().paused = false
	if GameManager.lives <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		var scene := "res://scenes/game.tscn" if level_number == 1 else "res://scenes/game_2.tscn"
		get_tree().change_scene_to_file(scene)
