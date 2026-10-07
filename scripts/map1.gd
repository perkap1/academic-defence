extends Node2D

const BuildSlotScene = preload("res://scenes/build_slot.tscn")
const GraduationEffect = preload("res://scripts/graduation_effect.gd")
const EnvironmentLayer = preload("res://scripts/environment_layer.gd")
const BUILD_POSITIONS := [Vector2(390, 285), Vector2(600, 392), Vector2(1083, 382), Vector2(1407, 481), Vector2(584, 643), Vector2(907, 601), Vector2(1390, 726), Vector2(259, 516), Vector2(894, 275)]
const ROUTE_POINTS := [Vector2(-60, 383), Vector2(180, 382), Vector2(345, 385), Vector2(410, 414), Vector2(443, 475), Vector2(461, 523), Vector2(514, 545), Vector2(632, 546), Vector2(724, 528), Vector2(834, 478), Vector2(930, 476), Vector2(1010, 491), Vector2(1060, 543), Vector2(1093, 597), Vector2(1148, 624), Vector2(1260, 628), Vector2(1371, 625), Vector2(1460, 600), Vector2(1536, 574), Vector2(1630, 574), Vector2(1715, 574)]

var level_id := 1
var level_title := "Skogsstien"
var build_positions := BUILD_POSITIONS
var route_points := ROUTE_POINTS

@onready var route: Path2D = get_node("Route") if has_node("Route") else get_node("UpperPath")
@onready var slots: Node2D = $BuildSlots
@onready var towers: Node2D = $Towers
@onready var projectiles: Node2D = $Projectiles
@onready var effects: Node2D = $Effects

func _ready() -> void:
	var environment = EnvironmentLayer.new()
	add_child(environment)
	environment.configure(level_id)
	route.curve = create_route_curve(route_points)
	for p in build_positions:
		var slot = BuildSlotScene.instantiate()
		slot.position = p
		slots.add_child(slot)

func create_route_curve(points: Array) -> Curve2D:
	var curve := Curve2D.new()
	curve.bake_interval = 3
	for i in range(points.size()):
		var p: Vector2 = points[i]
		var before: Vector2 = points[maxi(0, i - 1)]
		var after: Vector2 = points[mini(points.size() - 1, i + 1)]
		var tangent := (after - before).normalized()
		curve.add_point(p, -tangent * p.distance_to(before) * 0.25, tangent * p.distance_to(after) * 0.25)
	return curve

func get_routes() -> Array: return [route]
func get_students() -> Array:
	var result := []
	for path in get_routes(): result.append_array(path.get_children())
	return result
func nearest_road_point(point: Vector2) -> Vector2:
	var nearest := Vector2.ZERO
	var distance := INF
	for path in get_routes():
		var candidate: Vector2 = path.to_global(path.curve.get_closest_point(path.to_local(point)))
		if point.distance_squared_to(candidate) < distance:
			nearest = candidate
			distance = point.distance_squared_to(candidate)
	return nearest

func show_completion(student, graduated: bool) -> void:
	if graduated:
		var effect = GraduationEffect.new()
		effect.position = student.position
		effects.add_child(effect)
		return
	var label := Label.new()
	label.text = "−1 omdømme"
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("a3ffe0") if graduated else Color("ffc6a2"))
	label.add_theme_color_override("font_shadow_color", Color("152d29"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.position = student.position + Vector2(-58, -104)
	effects.add_child(label)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 1.1)
	tween.tween_property(label, "modulate:a", 0.0, 1.1)
	tween.chain().tween_callback(label.queue_free)

