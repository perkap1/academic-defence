extends PathFollow2D

signal resolved(student, graduated: bool)
const UnitLayout=preload("res://scripts/unit_layout.gd")
var lane_offset:=0.0
const AttackEffect = preload("res://scripts/attack_effect.gd")

const MAX_KNOWLEDGE := 100
var speed := 85.0
var base_speed := 85.0
var slow_remaining := 0.0
var slow_strength := 0.0
var slow_indicator := Sprite2D.new()
var drop_frames := []
var drop_time := 0.0
var teacher
var assistant_hold := false
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
	slow_strength = 0.0

func apply_slow(duration: float = 2.0, strength: float = 0.30) -> void:
	if done or duration <= 0:
		return
	if slow_remaining <= 0: drop_time = 0.0
	slow_remaining = maxf(slow_remaining, duration)
	# A weaker board cannot remove an existing stronger slow; neither stacks.
	slow_strength = maxf(slow_strength,clampf(strength,0,1))
	speed = base_speed * (1.0-slow_strength)
	slow_indicator.visible = true
	queue_redraw()

func show_wet_hit() -> void:
	if done: return
	var splash = AttackEffect.new()
	splash.configure("wet_splash",5,0.30)
	splash.position = Vector2(0,-17)
	add_child(splash)

func reserve_teacher(candidate) -> bool:
	if done or is_instance_valid(teacher): return false
	teacher=candidate
	return true

func release_teacher(candidate) -> void:
	if teacher==candidate:
		teacher=null
		assistant_hold=false

func face_teacher(point:Vector2) -> void:
	var vector:Vector2=point-global_position
	direction="side" if absf(vector.x)>absf(vector.y)*0.8 else ("front" if vector.y>0 else "back")
	sprite.flip_h=side_flipped(vector.x)
	sprite.texture=frames[direction][animation_frame()]

func update_lane_position()->void:
	if get_parent() is Path2D:
		position=UnitLayout.lane_position(get_parent().curve,progress,lane_offset)

func _ready() -> void:
	UnitLayout.apply_scale(self)
	lane_offset=UnitLayout.choose_lane()
	bar.scale=Vector2.ONE/UnitLayout.SCALE
	bar.position=Vector2(-40,-92)
	update_lane_position()
	rotates = false
	loop = false
	add_to_group("students")
	if student_type == "pe":
		frames=preload("res://scripts/pe_student_frames.gd").create(variant)
		sprite.offset=Vector2(-110,-210)
		sprite.scale=Vector2.ONE*0.43
	else:
		frames=preload("res://scripts/normal_student_frames.gd").create()
		sprite.offset=Vector2(-150,-310)
		sprite.scale=Vector2.ONE*0.28
	sprite.centered=false
	sprite.position=Vector2(0,-3)
	sprite.texture = frames["side"][2]
	sprite.flip_h = side_flipped(1)
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
	if not assistant_hold:
		progress = minf(progress + base_speed * (delta - slowed_time * slow_strength), length)
	update_lane_position()
	slow_remaining = maxf(0.0, slow_remaining - delta)
	if slow_remaining <= 0: slow_strength = 0.0
	speed = base_speed * (1.0-slow_strength)
	slow_indicator.visible = slow_remaining > 0
	if slow_remaining > 0:
		drop_time += delta
		slow_indicator.texture = drop_frames[int(drop_time*8) % drop_frames.size()]
	if slowed_time > 0:
		queue_redraw()
	animation_time += delta
	if assistant_hold:
		if is_instance_valid(teacher): face_teacher(teacher.global_position)
		else: assistant_hold=false
		return
	var tangent := path.curve.sample_baked(minf(progress + 4, length)) - path.curve.sample_baked(maxf(old_progress - 4, 0))
	if absf(tangent.y) > absf(tangent.x) * 0.8:
		direction = "front" if tangent.y > 0 else "back"
	else:
		direction = "side"
	sprite.flip_h = side_flipped(tangent.x)
	var frame := animation_frame()
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
	if is_instance_valid(teacher): teacher.student_completed(self)
	teacher=null
	assistant_hold=false
	slow_indicator.visible = false
	remove_from_group("students")
	hide()
	resolved.emit(self, graduated)
	queue_free()

func animation_frame() -> int:
	if assistant_hold: return int(animation_time*2) % 2
	return 2+int(animation_time*(10 if student_type=="pe" else 8)) % 4

func side_flipped(horizontal: float) -> bool:
	# Girl run poses face right, while her idle poses and the other sets face left.
	return direction=="side" and (horizontal<0 if student_type=="pe" and variant=="girl" and animation_frame() in [2,3,4] else horizontal>0)
