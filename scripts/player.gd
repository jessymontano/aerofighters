extends CharacterBody2D

# Velocidad de movimiento (fija, no depende de la skin elegida)
const SPEED = 400.0

# Rutas de las texturas de cada nave (solo visual)
const SHIP_TEXTURES := [
	"res://assets/sprites/player/ship_1.png",
	"res://assets/sprites/player/ship_2.png",
	"res://assets/sprites/player/ship_3.png",
	"res://assets/sprites/player/ship_4.png",
]

@export var bullet_scene:    PackedScene
@export var shoot_cooldown:  float = 0.18

var can_shoot:  bool = true
var is_dead:    bool = false
var invincible: bool = false
var powered_up: bool = false
var screen_size: Vector2

@onready var sprite:        Sprite2D            = $Sprite2D
@onready var shoot_timer:   Timer               = $ShootTimer
@onready var inv_timer:     Timer               = $InvincibleTimer
@onready var powerup_timer: Timer               = $PowerupTimer
@onready var shoot_sfx:     AudioStreamPlayer2D = $ShootSFX
@onready var hit_sfx:       AudioStreamPlayer2D = $HitSFX
var lose_sfx: AudioStream = preload("res://assets/audio/lose.ogg")

signal died


func _ready() -> void:
	add_to_group("player")
	screen_size = get_viewport_rect().size
	shoot_timer.wait_time = shoot_cooldown

	# Aplicar la skin seleccionada en el menú (solo cambia la textura)
	var idx := clampi(GameManager.selected_ship, 0, SHIP_TEXTURES.size() - 1)
	var tex := load(SHIP_TEXTURES[idx]) as Texture2D
	if tex:
		sprite.texture = tex


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var dir := Input.get_vector("left", "right", "up", "down")
	velocity = dir * SPEED
	move_and_slide()

	# Mantener al jugador dentro de la pantalla
	position.x = clamp(position.x, 20.0, screen_size.x - 20.0)
	position.y = clamp(position.y, 20.0, screen_size.y - 20.0)

	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()
		can_shoot = false
		shoot_timer.start()


func _shoot() -> void:
	if not bullet_scene:
		return

	# Las balas se añaden al nodo World para que no hereden la posición del jugador
	var world  := get_tree().get_first_node_in_group("world")
	var parent := world if world else get_parent()

	if powered_up:
		# Triple disparo en abanico cuando el powerup está activo
		for angle in [-12.0, 0.0, 12.0]:
			var b := bullet_scene.instantiate()
			b.global_position = $Muzzle.global_position
			b.direction = Vector2.UP.rotated(deg_to_rad(angle))
			parent.add_child(b)
	else:
		var b := bullet_scene.instantiate()
		b.global_position = $Muzzle.global_position
		b.direction = Vector2.UP
		parent.add_child(b)

	if shoot_sfx:
		shoot_sfx.play()


func activate_powerup() -> void:
	powered_up = true
	sprite.modulate = Color(0.5, 1.5, 2.0)
	powerup_timer.wait_time = 10.0
	powerup_timer.start()


func take_damage() -> void:
	if invincible or is_dead:
		return
	invincible = true
	inv_timer.start()

	# Parpadeo rojo al recibir daño
	var tw := create_tween().set_loops(4)
	tw.tween_property(sprite, "modulate", Color(1, 0.15, 0.15, 0.5), 0.08)
	tw.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.08)

	if hit_sfx:
		hit_sfx.play()

	if GameManager.lose_life() <= 0:
		_die()


func _die() -> void:
	shoot_sfx.stream = lose_sfx
	shoot_sfx.play()
	is_dead = true
	set_physics_process(false)
	died.emit()
	await get_tree().create_timer(0.8).timeout
	queue_free()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_invincible_timer_timeout() -> void:
	invincible = false

func _on_powerup_timer_timeout() -> void:
	powered_up = false
	sprite.modulate = Color(1, 1, 1)
