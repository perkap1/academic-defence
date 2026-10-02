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

func _ready() -> void:
	add_child(sprite)

func configure(student, amount: int) -> void:
	target = student
	knowledge = amount
	previous = position
	letter = ["A","B","C"][randi() % 3]
	flight_frames.clear()
	for i in range(3):
		flight_frames.append(load("res://assets/effects/letter_%s_%d.png" % [letter,i]))
	sprite.texture = flight_frames[0]

func _process(delta: float) -> void:
	if spent:
		return
	flight_time += delta
	if not flight_frames.is_empty():
		sprite.texture = flight_frames[int(flight_time*12) % 3]
	if not is_instance_valid(target) or target.done:
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
