extends CanvasLayer

var score_label:   Label
var lives_label:   Label
var powerup_icon:  TextureRect
var boss_bar_root: Control
var boss_fill:     TextureRect
@onready var player_hp_root: TextureRect = $TextureRect
var player_hp_container: HBoxContainer
@onready var hp_chunks: Array[TextureRect] = [
	$TextureRect/HBoxContainer/TextureRect,
	$TextureRect/HBoxContainer/TextureRect2,
	$TextureRect/HBoxContainer/TextureRect3
]
var boss_bar_frames: Array[Texture2D] = []
var boss_frame_texture: Texture2D
const BOSS_BAR_LEVELS := 6

const MAX_HP := 3

func _ready() -> void:
	_build_ui()
	GameManager.score_changed.connect(_update_score)
	GameManager.lives_changed.connect(_update_lives)
	GameManager.boss_hp_changed.connect(_update_boss_bar)
	_update_score(GameManager.score)
	_update_lives(GameManager.lives)

func _build_ui() -> void:
	var atlas = load("res://assets/ui/boss_bar.png")
	
	# ── SCORE (arriba derecha, solo) ───────────────────────
	score_label = Label.new()
	score_label.set_anchor(SIDE_RIGHT, 1.0)
	score_label.offset_left  = -180.0
	score_label.offset_top   = 6.0
	score_label.offset_right = -6.0
	score_label.offset_bottom = 24.0
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.text = "SCORE  0000000"
	score_label.add_theme_font_size_override("font_size", 14)
	score_label.add_theme_color_override("font_color", Color(0.2, 1, 0.5))
	add_child(score_label)

	# ── VIDAS + POWERUP (abajo izquierda) ─────────────────
	var bot := HBoxContainer.new()
	bot.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bot.offset_left   = 6.0
	bot.offset_top    = -24.0
	bot.offset_bottom = -4.0
	bot.add_theme_constant_override("separation", 6)
	add_child(bot)

	powerup_icon = TextureRect.new()
	powerup_icon.texture = load("res://assets/ui/icon-powerup.png")
	powerup_icon.custom_minimum_size = Vector2(18, 18)
	powerup_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	powerup_icon.visible = false
	bot.add_child(powerup_icon)

	# ── BOSS BAR (centro arriba, aparece solo con boss) ────
	var frame_tex := AtlasTexture.new()
	frame_tex.atlas = atlas
	frame_tex.region = Rect2(3, 67, 42, 11)
	
	boss_bar_root = TextureRect.new()
	boss_bar_root.texture = frame_tex
	boss_bar_root.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_bar_root.position = Vector2(-10, 12)
	boss_bar_root.scale = Vector2(2,2)
	boss_bar_root.pivot_offset = Vector2(21, 5.5)
	boss_bar_root.clip_contents = false
	boss_bar_root.visible = false
	add_child(boss_bar_root)
	
	var bar_positions = [55, 103, 151, 199, 247, 295]
	
	for x_pos in bar_positions:
		var frame := AtlasTexture.new()
		frame.atlas = atlas
		frame.region = Rect2(x_pos, 70, 34, 5)
		boss_bar_frames.append(frame)
		
	boss_fill = TextureRect.new()
	boss_fill.texture = boss_bar_frames[0]
	boss_fill.position = Vector2(21 - 17, 3)
	boss_bar_root.add_child(boss_fill)

func _update_score(val: int) -> void:
	score_label.text = "SCORE  %07d" % val

func _update_lives(count: int) -> void:
	for i in hp_chunks.size():
		hp_chunks[i].visible = i < count

func show_powerup(active: bool) -> void:
	powerup_icon.visible = active

func _update_boss_bar(pct: float) -> void:
	boss_bar_root.visible = pct > 0.0
	var index := int(floor((1.0 - pct) * (BOSS_BAR_LEVELS - 1)))
	index = clamp(index, 0, BOSS_BAR_LEVELS - 1)
	
	boss_fill.texture = boss_bar_frames[index]
