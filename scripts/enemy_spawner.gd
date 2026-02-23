extends Node

@export var enemy_1_scene: PackedScene
@export var enemy_2_scene: PackedScene
@export var boss_scene:    PackedScene

signal boss_dead

var screen_w: float = 360.0

# Estados posibles del spawner
enum State { IDLE, WAITING, BOSS_INTRO, BOSS_ALIVE, DONE }
var _state := State.IDLE

var _waves:       Array = []
var _wave_index:  int   = 0
var _group_index: int   = 0
var _bosses_left: int   = 0

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.name = "SpawnTimer"
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)


# Arranca el nivel — llamado por level.gd
func start_level(lv: int) -> void:
	_waves       = _get_waves(lv)
	_bosses_left = 2 if lv == 2 else 1
	_wave_index  = 0
	_group_index = 0
	_state       = State.WAITING
	_timer.wait_time = 1.5
	_timer.start()


func _on_timer_timeout() -> void:
	match _state:
		State.WAITING:
			_spawn_next()
		State.BOSS_INTRO:
			_do_spawn_boss()


# Decide qué hacer según el índice actual de oleada y grupo
func _spawn_next() -> void:
	if _wave_index >= _waves.size():
		_start_boss_intro()
		return

	var wave: Array = _waves[_wave_index]
	var grp:  Array = wave[_group_index]
	_spawn_group(_get_scene(grp[0]), grp[1])
	_group_index += 1

	if _group_index < wave.size():
		# Más grupos dentro de la misma oleada — pausa corta
		_timer.wait_time = 0.7
	else:
		# Oleada terminada — pausa larga antes de la siguiente
		_group_index = 0
		_wave_index += 1
		_timer.wait_time = 2.0

	_state = State.WAITING
	_timer.start()


# Limpia enemigos y activa la pausa dramática antes del boss
func _start_boss_intro() -> void:
	_state = State.BOSS_INTRO
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	_timer.wait_time = 1.5
	_timer.start()


# Instancia y añade el boss a la escena
func _do_spawn_boss() -> void:
	if not is_inside_tree():
		return
	if not boss_scene:
		push_error("EnemySpawner: boss_scene no está asignado en el inspector")
		return

	var boss := boss_scene.instantiate()
	boss.position = Vector2(screen_w / 2.0, -80.0)
	get_parent().add_child(boss)
	boss.tree_exited.connect(_on_boss_died, CONNECT_ONE_SHOT)
	_state = State.BOSS_ALIVE


# Llamado cuando el boss sale del árbol (muere)
func _on_boss_died() -> void:
	if not is_inside_tree():
		return
	_bosses_left -= 1
	if _bosses_left > 0:
		# Nivel 2: hay un segundo boss, pequeña pausa entre ellos
		_state = State.BOSS_INTRO
		_timer.wait_time = 1.0
		_timer.start()
	else:
		_state = State.DONE
		boss_dead.emit()


# Distribuye 'count' enemigos del tipo dado horizontalmente en el techo
func _spawn_group(scene: PackedScene, count: int) -> void:
	if not scene:
		return
	var margin  := 40.0
	var usable  := screen_w - margin * 2.0
	var spacing := usable / float(count)
	var target_positions := []
	for i in count:
		var cx := margin + spacing * i + spacing * 0.5
		var rx := randf_range(-spacing * 0.25, spacing * 0.25)
		var target_x : float = clamp(cx + rx, margin, screen_w - margin)
		target_positions.append(target_x)
		
	for i in count:
		var e  := scene.instantiate()
		e.position = Vector2(screen_w / 2.0, -20.0)
		get_parent().add_child(e)
		e.set_meta("target_x", target_positions[i])
		e.set_meta("target_y", -20.0)
		if e.has_method("move_to_position"):
			e.move_to_position(target_positions[i], -20.0, 0.5)


# Oleadas por nivel. Cada grupo es [tipo, cantidad].
# Tipo 1 = enemigo normal  |  Tipo 2 = enemigo rápido
func _get_waves(lv: int) -> Array:
	if lv == 1:
		return [
			[[1, 4]],
			[[2, 3]],
			[[1, 3], [2, 2]],
			[[1, 5]],
			[[2, 4]],
		]
	else:
		return [
			[[1, 5]],
			[[2, 5]],
			[[1, 4], [2, 3]],
			[[2, 6]],
			[[1, 5], [2, 4]],
		]


func _get_scene(tipo: int) -> PackedScene:
	return enemy_1_scene if tipo == 1 else enemy_2_scene
