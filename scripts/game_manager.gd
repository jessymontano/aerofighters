extends Node

var score: int = 0
var lives: int = 3
var current_level: int = 1
var selected_ship: int = 0

const POINTS := { "normal": 100, "fast": 200, "boss": 1000 }

signal score_changed(val: int)
signal lives_changed(val: int)
signal boss_hp_changed(pct: float)  # para la barra del boss en el HUD

func reset() -> void:
	score = 0
	lives = 3
	current_level = 1

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func lose_life() -> int:
	lives -= 1
	lives_changed.emit(lives)
	return lives

func update_boss_hp(current: int, maximum: int) -> void:
	var pct := float(current) / float(maximum) if maximum > 0 else 0.0
	boss_hp_changed.emit(pct)

func gain_life() -> void:
	lives = mini(lives + 1, 3)
	lives_changed.emit(lives)
