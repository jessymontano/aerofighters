extends CharacterBody2D

const SPEED = 300.0
@export var hp: int = 1
@export var score_value: int = 100
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, SPEED)
	move_and_slide()

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = Vector2.DOWN
		get_parent().add_child(bullet)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_shoot_timer_timeout() -> void:
	shoot()
