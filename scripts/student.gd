extends PathFollow2D

signal resolved(student, graduated: bool)
const AttackEffect = preload("res://scripts/attack_effect.gd")

const MAX_KNOWLEDGE := 100
var speed := 85.0
var base_speed := 85.0
var slow_remaining := 0.0
var slow_indicator := Sprite2D.new()
var drop_frames := []
var drop_time := 0.0
var knowledge := 0
var done := false
var animation_time := 0.0
var direction := "side"
var frames := {}
var student_type := "normal"
var variant := "boy"
@onready var sprite: Sprite2D = $Sprite
@onready var bar: ProgressBar = $KnowledgeBar

func configure(kind: String, sex: String = "boy") -> void:
	student_type = "pe" if kind == "pe" else "normal"
	variant = "girl" if sex == "girl" else "boy"
	speed = 114.75 if student_type == "pe" else 85.0
	base_speed = speed
	slow_remaining = 0.0

func apply_slow(duration: float = 2.0) -> void:
	if done or duration <= 0:
		return
	if slow_remaining <= 0: drop_time = 0.0
	slow_remaining = maxf(slow_remaining, duration)
	speed = base_speed * 0.70
	slow_indicator.visible = true
	queue_redraw()

func show_wet_hit() -> void:
	if done: return
	var splash = AttackEffect.new()
	splash.configure("wet_splash",5,0.30)
	splash.position = Vector2(0,-17)
	add_child(splash)

func _ready() -> void:
	rotates = false
	loop = false
	add_to_group("students")
	for key in ["front", "side", "back"]:
		frames[key] = []
		for i in range(6):
			var prefix := "pe_%s" % variant if student_type == "pe" else "student"
			frames[key].append(load("res://assets/%s_%s_%d.png" % [prefix, key, i]))
	sprite.texture = frames["side"][2]
	sprite.flip_h = true
	var background := StyleBoxFlat.new()
	background.bg_color = Color("102e31")
	background.set_border_width_all(2)
	background.border_color = Color("fff1c6")
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("8ecfff") if student_type == "pe" else Color("64dfc5")
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	bar.value = knowledge
	for i in range(3):
		drop_frames.append(load("res://assets/effects/slow_drop_%d.png" % i))
	slow_indicator.position = Vector2(27,-65)
	slow_indicator.texture = drop_frames[0]
	slow_indicator.visible = slow_remaining > 0
	add_child(slow_indicator)
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, -3), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 23, Color(0.03, 0.08, 0.09, 0.35))
	draw_set_transform(Vector2.ZERO)

func _process(delta: float) -> void:
	if done or not get_parent() is Path2D:
		return
	var path: Path2D = get_parent()
	var length := path.curve.get_baked_length()
	var old_progress := progress
	# Split a long frame at expiry so the un-slowed part travels at base speed.
	var slowed_time := minf(delta, slow_remaining)
	progress = minf(progress + base_speed * (delta - slowed_time * 0.30), length)
	slow_remaining = maxf(0.0, slow_remaining - delta)
	speed = base_speed * 0.70 if slow_remaining > 0 else base_speed
	slow_indicator.visible = slow_remaining > 0
	if slow_remaining > 0:
		drop_time += delta
		slow_indicator.texture = drop_frames[int(drop_time*8) % 3]
	if slowed_time > 0:
		queue_redraw()
	var tangent := path.curve.sample_baked(minf(progress + 4, length)) - path.curve.sample_baked(maxf(old_progress - 4, 0))
	if absf(tangent.y) > absf(tangent.x) * 0.8:
		direction = "front" if tangent.y > 0 else "back"
	else:
		direction = "side"
	sprite.flip_h = direction == "side" and tangent.x > 0
	animation_time += delta
	var frame := 2 + int(animation_time * 8) % 4
	sprite.texture = frames[direction][frame]
	if progress >= length:
		complete(false)

func teach(amount: int) -> void:
	if done:
		return
	knowledge = clampi(knowledge + amount, 0, MAX_KNOWLEDGE)
	bar.value = knowledge
	sprite.modulate = Color(1.3, 1.3, 0.8)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.18)
	if knowledge == MAX_KNOWLEDGE:
		complete(true)

func complete(graduated: bool) -> void:
	if done:
		return
	done = true
	slow_indicator.visible = false
	remove_from_group("students")
	hide()
	resolved.emit(self, graduated)
	queue_free()
