extends Node2D

var target
var knowledge := 20
var speed := 640.0
var spent := false
var previous := Vector2.ZERO
var letter := "A"
var flight_frames := []
var flight_time := 0.0
var sprite := Sprite2D.new()
var golden := false

func _ready() -> void:
	add_child(sprite)

func configure(student, amount: int, is_golden: bool = false) -> void:
	golden = is_golden
	sprite.modulate = Color(1.4,1.18,0.75) if golden else Color.WHITE
	sprite.scale = Vector2.ONE * (0.0875 if golden else 0.07)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	target = student
	knowledge = amount
	previous = position
	letter = ["A","B","C"][randi() % 3]
	flight_frames.clear()
	flight_frames.append(preload("res://scripts/tower_presentation.gd").thrown_book())
	sprite.texture = flight_frames[0]
	queue_redraw()

func _draw() -> void:
	if not golden: return
	for i in range(4):
		var point := Vector2.from_angle(flight_time*2+i*TAU/4) * 31
		point = point.round()
		draw_rect(Rect2(point-Vector2(2,6),Vector2(4,12)),Color("ffe873"))
		draw_rect(Rect2(point-Vector2(6,2),Vector2(12,4)),Color("fff4b2"))

func _process(delta: float) -> void:
	if spent:
		return
	flight_time += delta
	if golden: queue_redraw()
	if not flight_frames.is_empty():
		sprite.texture = flight_frames[0]
		sprite.rotation = flight_time*12.0
	if not is_instance_valid(target) or not target.is_targetable():
		spent = true
		queue_free()
		return
	var destination: Vector2 = target.global_position + Vector2(0, -40)
	var distance := global_position.distance_to(destination)
	if distance <= speed * delta + 8:
		spent = true
		target.teach(knowledge)
		queue_free()
	else:
		global_position = global_position.move_toward(destination, speed * delta)
