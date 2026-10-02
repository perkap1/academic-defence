extends Node2D

const ProjectileScene = preload("res://scenes/projectile.tscn")
var tower_type := "book"
var teaching_range := 260.0
var fire_interval := 1.0
var knowledge_per_hit := 20
var cooldown := 0.0
var animation_time := 0.0
var show_range := false
var map
var game
var frames := []
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	for i in range(5):
		frames.append(load("res://assets/tower_%d.png" % i))
	sprite.texture = frames[0]

func configure(level, manager) -> void:
	map = level
	game = manager

func _draw() -> void:
	if show_range:
		draw_circle(Vector2.ZERO, teaching_range, Color(0.45, 0.85, 0.78, 0.10))
		draw_arc(Vector2.ZERO, teaching_range, 0, TAU, 96, Color(0.72, 1, 0.87, 0.6), 2)

func set_range_visible(visible_range: bool) -> void:
	show_range = visible_range
	queue_redraw()

func _process(delta: float) -> void:
	if game == null or game.finished:
		return
	cooldown = maxf(0, cooldown - delta)
	animation_time = maxf(0, animation_time - delta)
	sprite.texture = frames[2] if animation_time > 0 else frames[0]
	if cooldown > 0:
		return
	var nearest = null
	var closest := teaching_range
	for student in map.route.get_children():
		if not is_instance_valid(student) or student.done:
			continue
		var distance := global_position.distance_to(student.global_position)
		if distance <= closest:
			nearest = student
			closest = distance
	if nearest != null:
		var projectile = ProjectileScene.instantiate()
		map.projectiles.add_child(projectile)
		projectile.global_position = global_position + Vector2(0, -102)
		projectile.configure(nearest, knowledge_per_hit)
		cooldown = fire_interval
		animation_time = 0.25
