extends Node

@export var enemy_1_scene: PackedScene
@export var spawn_interval: float = 1.5

var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	var enemy_scene = enemy_1_scene
	spawn_enemy(enemy_scene)

func spawn_enemy(enemy_scene: PackedScene):
	var enemy = enemy_scene.instantiate()
	enemy.position.x = randf_range(20, screen_size.x - 20)
	enemy.position.y = -20
	get_node("..").add_child(enemy)
