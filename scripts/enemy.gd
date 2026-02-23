extends CharacterBody2D

const SPEED = 100.0

@export var hp: int = 1
@export var score_type: String = "normal"
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2

const EXPLOSION   = preload("res://scenes/explosion.tscn")
const HEALTH_DROP = preload("res://scenes/pickup_health.tscn")
const POWERUP_DROP = preload("res://scenes/pickup_power.tscn")

# Probabilidades de soltar un pickup al morir
const DROP_HEALTH_CHANCE := 0.12
const DROP_POWER_CHANCE  := 0.07

var screen_size: Vector2

@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSFX
@onready var explode_sfx: AudioStreamPlayer2D = $ExplodeSFX


func _ready() -> void:
	add_to_group("enemies")
	screen_size = get_viewport_rect().size


func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, SPEED)
	move_and_slide()


func take_damage(amount: int) -> void:
	hp -= amount
	# Flash blanco al recibir impacto
	$AnimatedSprite2D.modulate = Color(2.5, 2.5, 2.5)
	await get_tree().create_timer(0.07).timeout
	if is_instance_valid(self):
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
	if hp <= 0:
		_die()


func _die() -> void:
	if explode_sfx:
		explode_sfx.reparent(get_tree().current_scene)
		explode_sfx.global_position = global_position
		explode_sfx.play()

	GameManager.add_score(GameManager.POINTS.get(score_type, 100))
	_spawn_explosion()
	_try_drop()
	queue_free()


func _spawn_explosion() -> void:
	var expl := EXPLOSION.instantiate()
	expl.position = global_position
	get_parent().add_child(expl)


# Tira un pickup al azar con cierta probabilidad
func _try_drop() -> void:
	var roll := randf()
	if roll < DROP_HEALTH_CHANCE:
		var drop := HEALTH_DROP.instantiate()
		drop.position = global_position
		get_parent().add_child(drop)
	elif roll < DROP_HEALTH_CHANCE + DROP_POWER_CHANCE:
		var drop := POWERUP_DROP.instantiate()
		drop.position = global_position
		get_parent().add_child(drop)


func shoot() -> void:
	if not bullet_scene:
		return
	var b := bullet_scene.instantiate()
	b.global_position = global_position + Vector2(0, 18)
	b.direction = Vector2.DOWN
	get_parent().add_child(b)
	
	if shoot_sfx:
		shoot_sfx.play()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_shoot_timer_timeout() -> void:
	shoot()


func _on_player_detector_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func move_to_position(target_x: float, target_y: float, duration: float) -> void:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(self, "position:x", target_x, duration)
		
		await tween.finished
	
