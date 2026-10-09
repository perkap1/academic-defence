extends Area2D

signal build_requested(slot)
const Blockers = preload("res://scripts/site_blockers.gd")
var blocked_variant := ""
var obstacle: Sprite2D
var obstacle_collision: CollisionShape2D
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

func set_blocker(variant: String) -> void:
	blocked_variant = variant
	if not is_instance_valid(obstacle):
		obstacle = Sprite2D.new()
		obstacle.name = "Obstacle"
		obstacle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		obstacle.centered = false
		obstacle.position = Vector2(-57,-82)
		obstacle.scale = Vector2.ONE * 0.34
		add_child(obstacle)
	if not is_instance_valid(obstacle_collision):
		obstacle_collision = CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(114,110)
		obstacle_collision.shape = shape
		obstacle_collision.position = Vector2(0,-27)
		add_child(obstacle_collision)
	obstacle_collision.set_deferred("disabled",not is_blocked())
	obstacle.visible = is_blocked()
	update_obstacle()
	queue_redraw()

func is_blocked() -> bool: return not blocked_variant.is_empty()
func get_clear_cost() -> int: return Blockers.cost(blocked_variant)
func update_obstacle() -> void:
	if is_instance_valid(obstacle) and is_blocked():
		obstacle.texture = Blockers.texture(blocked_variant,hovered)

func refresh_visuals() -> void:
	tower_collision.set_deferred("disabled",not occupied)
	queue_redraw()

func on_input(_viewport, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		build_requested.emit(self)
		get_viewport().set_input_as_handled()

func set_hover(value: bool) -> void:
	hovered = value
	update_obstacle()
	queue_redraw()

func _draw() -> void:
	if is_blocked(): return
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
