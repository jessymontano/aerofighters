extends CharacterBody2D

const SPEED = 400.0
@export var hp = 3
@export var bullet_scene: PackedScene
@export var powerup_duration: float = 20.0

var can_shoot: bool = true
var shoot_cooldown: float = 0.2
var powerup_active: bool = false
var normal_shoot_cooldown: float
var powerup_time_left: float = 0.0

@onready var shoot_timer: Timer = $ShootTimer
@onready var powerup_timer: Timer = $PowerupTimer

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size

	
func _physics_process(delta: float) -> void:
	# move
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED
	move_and_slide()
	
	# wrap around screen
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
		shoot_timer.start(shoot_cooldown)
	
func shoot():
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = $Muzzle.global_position
	bullet.direction = Vector2.UP
	get_parent().add_child(bullet)



func _on_shoot_timer_timeout() -> void:
	can_shoot = true
