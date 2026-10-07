extends "res://scripts/book_tower.gd"
const AttackEffect = preload("res://scripts/attack_effect.gd")

var area_radius := 105.0
var slow_duration := 2.0
var slow_strength := 0.30

func _ready() -> void:
	tower_type = "blackboard"
	total_invested = 100
	teaching_range = 225.0
	fire_interval = 1.3
	knowledge_per_hit = 15
	Presentation.apply(self)

func upgrade_level() -> bool:
	if not super.upgrade_level(): return false
	area_radius = [105.0,126.0,147.0][level-1]
	knowledge_per_hit = [15,19,22][level-1]
	slow_duration = 2.5
	slow_strength = 0.40 if level == 3 else 0.30
	return true

func get_visual_frame() -> int:
	if animation_time<=0:return 0
	return 1+clampi(int(floor((0.4-animation_time)*10.0+0.00001)),0,3)

func create_attack_effect():
	var effect=AttackEffect.new()
	effect.configure_blackboard(level)
	effect.sprite.scale=Vector2.ONE*([0.66,0.74,0.82][level-1])
	return effect

func _process(delta: float) -> void:
	if game == null or game.finished:
		return
	cooldown = maxf(0, cooldown - delta)
	animation_time = maxf(0, animation_time - delta)
	update_sprite(delta)
	queue_redraw()
	if cooldown > 0:
		return
	var nearest = null
	var closest := teaching_range
	for student in map.get_students():
		if not student.done:
			var distance := global_position.distance_to(student.global_position)
			if distance <= closest:
				nearest = student
				closest = distance
	if nearest == null:
		return
	var center: Vector2 = nearest.global_position
	var swipe = create_attack_effect()
	map.effects.add_child(swipe)
	swipe.global_position = center
	# Snapshot the group: a teaching hit may graduate and remove a student.
	for student in map.get_students():
		if is_instance_valid(student) and not student.done and student.global_position.distance_to(center) <= area_radius:
			student.apply_slow(slow_duration,slow_strength)
			student.show_wet_hit()
			student.teach(knowledge_per_hit)
	animation_time = 0.4
	update_sprite(0)
	cooldown = fire_interval
