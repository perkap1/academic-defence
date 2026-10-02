extends Area2D

signal build_requested(slot)
var occupied := false
var hovered := false
var affordable := true
var tower
var tower_collision: CollisionShape2D

func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(func(): set_hover(true))
	mouse_exited.connect(func(): set_hover(false))
	input_event.connect(on_input)
	if not has_node("CollisionShape2D"):
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 46
		collision.shape = shape
		add_child(collision)
	tower_collision = CollisionShape2D.new()
	var tower_shape := RectangleShape2D.new()
	tower_shape.size = Vector2(126,174)
	tower_collision.shape = tower_shape
	tower_collision.position = Vector2(0,-65)
	tower_collision.disabled = true
	add_child(tower_collision)
	queue_redraw()

func refresh_visuals() -> void:
	tower_collision.set_deferred("disabled",not occupied)
	queue_redraw()

func on_input(_viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		build_requested.emit(self)
		get_viewport().set_input_as_handled()

func set_hover(value: bool) -> void:
	hovered = value
	queue_redraw()

func _draw() -> void:
	if occupied:
		# The map contains a painted placeholder; keep it covered under the tower.
		draw_circle(Vector2.ZERO,24,Color("173c2b"))
		return
	var color := Color("ffe7a0") if affordable else Color("baa697")
	draw_circle(Vector2.ZERO, 44, Color("173c2b"))
	draw_arc(Vector2.ZERO, 41, 0, TAU, 48, color, 4)
	draw_line(Vector2(-13, 0), Vector2(13, 0), color, 5)
	draw_line(Vector2(0, -13), Vector2(0, 13), color, 5)
	if hovered:
		draw_circle(Vector2.ZERO, 44, Color(1, 0.86, 0.48, 0.18))
