extends Node2D
const Artwork = preload("res://scripts/economy_artwork.gd")
const BRANCHES := ["library","scholarship","research"]
const NAMES := {"study":"Study Hall","library":"Library","scholarship":"Scholarship Office","research":"Research Institute"}
const SPECIALIZATION_COST := 120
const SCHOLARSHIP_RADIUS := 260.0
var tower_type := "economy"
var branch := "study"
var total_invested := 100
var wave_bonus := 0
var research_payouts := 0
var show_range := false
var visual_time := 0.0
var active_time := 0.0
var frames := []
var game
var map
@onready var sprite: Sprite2D = $Sprite
var base_sprite: Sprite2D
func _ready() -> void:
	sprite.centered = false
	sprite.offset = Vector2(-180,-290)
	sprite.scale = Vector2.ONE * 0.58
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	base_sprite = Sprite2D.new()
	base_sprite.centered = false
	base_sprite.offset = sprite.offset
	base_sprite.scale = sprite.scale
	base_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(base_sprite)
	move_child(base_sprite,0)
	# Keep the stone base still while pages, windows and light animate above it.
	for pair in [[base_sprite,false],[sprite,true]]:
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/tower_base.gdshader")
		material.set_shader_parameter("cut_y",-35.0)
		material.set_shader_parameter("upper",pair[1])
		pair[0].material = material
	apply_artwork()
func configure(level, manager) -> void:
	map = level
	game = manager
func apply_artwork() -> void:
	frames = Artwork.frames(branch)
	sprite.texture = frames[0]
	base_sprite.texture = frames[0]
func specialize(choice: String) -> bool:
	if branch != "study" or choice not in BRANCHES: return false
	branch = choice
	total_invested += SPECIALIZATION_COST
	visual_time = 0.0
	active_time = 0.0
	apply_artwork()
	queue_redraw()
	return true
func get_display_name() -> String: return NAMES[branch]
func get_sell_refund() -> int: return int(total_invested / 2)
func get_income() -> int:
	match branch:
		"library": return 45
		"scholarship": return 10
		"research": return mini(15 + 10 * research_payouts,65)
	return 15
func get_next_income() -> int:
	return mini(get_income()+10,65) if branch == "research" else get_income()
func set_range_visible(value: bool) -> void:
	show_range = value and branch == "scholarship"
	queue_redraw()
func show_income(amount: int) -> void:
	active_time = 0.45
	sprite.texture = frames[4]
	var popup := Label.new()
	popup.text = "+%d KP" % amount
	popup.position = Vector2(-60,-160)
	popup.size = Vector2(120,30)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size",22)
	popup.add_theme_color_override("font_color",Color("ffe58a"))
	popup.add_theme_color_override("font_outline_color",Color("142b29"))
	popup.add_theme_constant_override("outline_size",5)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(popup)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(popup,"position:y",-183.0,0.75)
	tween.tween_property(popup,"modulate:a",0.0,0.75).set_delay(0.2)
	tween.chain().tween_callback(popup.queue_free)
func _process(delta: float) -> void:
	visual_time += delta
	active_time = maxf(0,active_time-delta)
	sprite.texture = frames[4] if active_time > 0 else frames[int(visual_time*3) % 4]
func _draw() -> void:
	if show_range:
		draw_circle(Vector2.ZERO,SCHOLARSHIP_RADIUS,Color(0.40,0.78,0.52,0.09))
		draw_arc(Vector2.ZERO,SCHOLARSHIP_RADIUS,0,TAU,96,Color(0.70,0.91,0.60,0.65),2)
