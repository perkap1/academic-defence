extends RefCounted

const ROOT := "res://assets/ui/"

static func image(parent: Node, name: String, pos: Vector2, dimensions: Vector2) -> TextureRect:
	var item := TextureRect.new()
	item.texture = load(ROOT + name + ".png")
	item.position = pos
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.size = dimensions
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	# Adding a textured Control can refresh its cached minimum size.
	item.size = dimensions
	return item

static func panel(parent: Node, pos: Vector2, dimensions: Vector2, tooltip: bool = false) -> NinePatchRect:
	var item := NinePatchRect.new()
	item.texture = load(ROOT + ("tooltip.png" if tooltip else "panel.png"))
	item.position = pos
	item.size = dimensions
	item.patch_margin_left = 65 if tooltip else 100
	item.patch_margin_right = 65 if tooltip else 100
	item.patch_margin_top = 35 if tooltip else 55
	item.patch_margin_bottom = 35 if tooltip else 70
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

static func label(parent: Node, text: String, pos: Vector2, dimensions: Vector2, font_size: int = 22, color: Color = Color("fff0c7")) -> Label:
	var item := Label.new()
	item.text = text
	item.position = pos
	item.size = dimensions
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.add_theme_color_override("font_shadow_color", Color("0a1617"))
	item.add_theme_constant_override("shadow_offset_x", 2)
	item.add_theme_constant_override("shadow_offset_y", 2)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

static func framed_button(parent: Node, family: String, pos: Vector2, dimensions: Vector2) -> TextureButton:
	var item := TextureButton.new()
	item.texture_normal = load(ROOT + family + "_normal.png")
	item.texture_hover = load(ROOT + family + "_hover.png")
	item.texture_pressed = load(ROOT + family + ("_selected.png" if family == "tower_frame" else "_pressed.png"))
	item.texture_disabled = load(ROOT + family + "_disabled.png")
	item.ignore_texture_size = true
	item.stretch_mode = TextureButton.STRETCH_SCALE
	item.position = pos
	item.size = dimensions
	item.focus_mode = Control.FOCUS_NONE
	parent.add_child(item)
	return item

static func action(parent: Node, text: String, pos: Vector2, dimensions: Vector2 = Vector2(245,114)) -> TextureButton:
	var item := framed_button(parent, "action", pos, dimensions)
	var caption := label(item, text, Vector2(dimensions.x * 0.30, dimensions.y * 0.19), Vector2(dimensions.x * 0.49, dimensions.y * 0.55), 21)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return item

static func plain_button(parent: Node, text: String, pos: Vector2, dimensions: Vector2) -> Button:
	var item := Button.new()
	item.position = pos
	item.size = dimensions
	item.text = text
	item.add_theme_font_size_override("font_size", 24)
	item.add_theme_color_override("font_color", Color("fff0bd"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("18362e")
	normal.border_color = Color("daa941")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	var hover := normal.duplicate()
	hover.bg_color = Color("31513c")
	item.add_theme_stylebox_override("normal", normal)
	item.add_theme_stylebox_override("hover", hover)
	item.add_theme_stylebox_override("pressed", normal)
	parent.add_child(item)
	return item

static func icon_button(parent: Node, icon: String, pos: Vector2, dimensions: Vector2) -> Button:
	var item := plain_button(parent, "", pos, dimensions)
	for state in ["normal", "hover", "pressed", "focus"]:
		item.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var picture := image(item, "icon_" + icon, Vector2.ZERO, dimensions)
	item.mouse_entered.connect(func(): picture.modulate = Color(1.2,1.2,1.05))
	item.mouse_exited.connect(func(): picture.modulate = Color.WHITE)
	return item
