extends Node2D

const Presentation=preload("res://scripts/tower_presentation.gd")
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
var base_sprite: Sprite2D
var level := 1
var total_invested := 70
var visual_time := 0.0
var level3_shots := 0
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	Presentation.apply(self)
	var badge=preload("res://scripts/book_level_badge.gd").new()
	badge.name="LevelBadge"
	badge.z_index=2
	badge.scale=Vector2.ONE*0.65
	add_child(badge)

func configure(level, manager) -> void:
	map = level
	game = manager
	Presentation.face_entrance(self,map)

func get_upgrade_cost() -> int:
	if level >= 3: return 0
	return [80,130][level-1] if tower_type == "book" else [100,150][level-1]

func get_display_name() -> String:
	return ["Book Tower","Advanced Book Tower","Scholar Tower"][level-1] if tower_type == "book" else ["Science Tower","Advanced Science Tower","Master Science Tower"][level-1]

func get_sell_refund() -> int:
	return int(total_invested / 2)

func upgrade_level() -> bool:
	var cost := get_upgrade_cost()
	if cost == 0: return false
	total_invested += cost
	level += 1
	if tower_type == "book":
		knowledge_per_hit = [20,25,30][level-1]
		fire_interval = [1.0,0.8,0.65][level-1]
		teaching_range = [260.0,286.0,312.0][level-1]
	Presentation.apply(self)
	update_sprite(0)
	if has_node("LevelBadge"): get_node("LevelBadge").queue_redraw()
	queue_redraw()
	return true

func get_visual_frame() -> int:
	if animation_time > 0: return 8+clampi(int(floor((0.4-animation_time)*10.0+0.00001)),0,3)
	return int(floor(visual_time*3.0))%8

func update_sprite(delta: float) -> void:
	visual_time += delta
	sprite.texture = frames[get_visual_frame()]

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
	update_sprite(delta)
	if cooldown > 0:
		return
	var nearest = null
	var closest := teaching_range
	for student in map.get_students():
		if not is_instance_valid(student) or not student.is_targetable():
			continue
		var distance := global_position.distance_to(student.global_position)
		if distance <= closest:
			nearest = student
			closest = distance
	if nearest != null:
		var projectile = ProjectileScene.instantiate()
		map.projectiles.add_child(projectile)
		projectile.global_position = global_position + Vector2(0, -66.3)
		if level == 3: level3_shots += 1
		var golden := level == 3 and level3_shots % 5 == 0
		projectile.configure(nearest, knowledge_per_hit * (2 if golden else 1), golden)
		cooldown = fire_interval
		animation_time = 0.4
		update_sprite(0)
