extends "res://scripts/enemy.gd"

# Posición Y donde el boss para y empieza a moverse horizontalmente
@export var stop_y: float = 120.0
# Segundo tipo de bala (disparo alternado)
@export var bullet_scene_2: PackedScene

const MAX_HP := 20

var _shoot_count := 0


func _ready() -> void:
	hp = MAX_HP
	score_type = "boss"
	shoot_interval = 0.85
	add_to_group("enemies")
	screen_size = get_viewport_rect().size
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()
	GameManager.update_boss_hp(hp, MAX_HP)


func _physics_process(_delta: float) -> void:
	if position.y < stop_y:
		# Bajar hasta la posición de parada
		velocity = Vector2(0, 130.0)
	else:
		# Moverse de lado a lado usando una onda seno
		velocity = Vector2(sin(Time.get_ticks_msec() * 0.0011) * 90.0, 0.0)
	move_and_slide()


func take_damage(amount: int) -> void:
	hp -= amount
	# Flash blanco al recibir daño
	var spr := $Sprite2D
	if spr:
		spr.modulate = Color(2.5, 2.5, 2.5)
		await get_tree().create_timer(0.07).timeout
		if is_instance_valid(self):
			spr.modulate = Color(1, 1, 1)
	GameManager.update_boss_hp(maxi(hp, 0), MAX_HP)
	if hp <= 0:
		_die()


func _die() -> void:
	GameManager.add_score(GameManager.POINTS.get(score_type, 1000))
	GameManager.update_boss_hp(0, MAX_HP)
	_spawn_explosion()
	# Explosiones adicionales para hacer la muerte más espectacular
	for i in 3:
		await get_tree().create_timer(0.15).timeout
		if not is_instance_valid(self):
			break
		var expl := EXPLOSION.instantiate()
		if explode_sfx:
			explode_sfx.reparent(get_tree().current_scene)
			explode_sfx.global_position = global_position
			explode_sfx.play()
		expl.position = global_position + Vector2(randf_range(-30, 30), randf_range(-20, 20))
		expl.scale = Vector2(3.5, 3.5)
		get_parent().add_child(expl)
	queue_free()


func shoot() -> void:
	# Alternar entre las dos escenas de bala
	_shoot_count += 1
	var scene := bullet_scene_2 if bullet_scene_2 and _shoot_count % 2 == 0 else bullet_scene
	if not scene:
		return
	# Disparar tres balas en abanico
	for deg in [-20, 0, 20]:
		var b := scene.instantiate()
		b.global_position = global_position + Vector2(0, 30)
		b.direction = Vector2.DOWN.rotated(deg_to_rad(float(deg)))
		get_parent().add_child(b)
		
	if shoot_sfx:
		shoot_sfx.play()
