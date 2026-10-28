extends "res://scripts/book_tower.gd"
const ScienceAttack = preload("res://scripts/science_attack.gd")
const SOURCE_PIVOTS=[Vector2(146.5,502),Vector2(390.5,501),Vector2(631.5,501),Vector2(870.5,501),Vector2(1106,501),Vector2(1337.5,501),Vector2(155.5,1012),Vector2(442,1012),Vector2(724.5,1012),Vector2(1027.5,1012),Vector2(1310,1012)]

var area_radius := 105.0
var slow_duration := 2.0
var slow_strength := 0.30

func _ready() -> void:
	tower_type = "blackboard"
	total_invested = 120
	teaching_range = 225.0
	fire_interval = 1.3
	knowledge_per_hit = 15
	Presentation.apply(self)
	var badge=preload("res://scripts/book_level_badge.gd").new()
	badge.name="LevelBadge"
	badge.z_index=2
	badge.scale=Vector2.ONE*0.65
	add_child(badge)

func upgrade_level() -> bool:
	if not super.upgrade_level(): return false
	area_radius = [105.0,126.0,147.0][level-1]
	knowledge_per_hit = [15,19,22][level-1]
	slow_duration = 2.5
	slow_strength = 0.40 if level == 3 else 0.30
	return true

func get_visual_frame() -> int:
	if animation_time<=0:return int(floor(visual_time*1.5+0.00001))%6
	return 6+clampi(int(floor((0.4-animation_time)*12.5+0.00001)),0,4)

func update_sprite(delta:float)->void:
	super.update_sprite(delta)
	var frame:=get_visual_frame()
	sprite.material.set_shader_parameter("science_frame",frame)
	sprite.material.set_shader_parameter("source_pivot",SOURCE_PIVOTS[frame])
	sprite.material.set_shader_parameter("source_flipped",sprite.flip_h)

func create_attack_effect():
	var effect=ScienceAttack.new()
	effect.configure_science(level,area_radius)
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
		if student.can_receive_attack("blackboard"):
			var distance := global_position.distance_to(student.global_position)
			if distance <= closest:
				nearest = student
				closest = distance
	if nearest == null:
		return
	var center: Vector2 = nearest.predict_position(ScienceAttack.FLIGHT_TIME)
	var swipe = create_attack_effect()
	swipe.configure_impact(map,knowledge_per_hit,area_radius,slow_duration,slow_strength)
	swipe.source_stats = stats
	stats.add("shots")
	map.effects.add_child(swipe)
	swipe.global_position = center
	swipe.launch_from(global_position+Vector2(0,-65))
	animation_time = 0.4
	update_sprite(0)
	cooldown = fire_interval
