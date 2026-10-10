extends "res://scripts/attack_effect.gd"
signal landed
const Presentation=preload("res://scripts/tower_presentation.gd")
const FLIGHT_TIME := 0.7
const ARC_HEIGHT := 100.0
var orb_frames:=[]
var orb:=Sprite2D.new()
var launch_offset:=Vector2.ZERO
var flight_duration:=0.0
var impacted:=false
var ground_position:=Vector2.ZERO
var map
var source_stats
var hit_knowledge:=0
var hit_radius:=0.0
var hit_duration:=0.0
var hit_strength:=0.0
func configure_science(level:int,radius:float)->void:
	configure("science_cloud",5,0.45)
	effect_level=level
	frames=Presentation.science_cloud_frames()
	orb_frames=Presentation.science_orb_frames()
	sprite.scale=Vector2.ONE*(radius*2.0/360.0)
	sprite.centered=false
	sprite.offset=Vector2(-200,-330)
func configure_impact(level_map,knowledge:int,radius:float,slow_seconds:float,strength:float)->void:
	map=level_map
	hit_knowledge=knowledge
	hit_radius=radius
	hit_duration=slow_seconds
	hit_strength=strength
func launch_from(point:Vector2)->void:
	launch_offset=point+Vector2(0,65)-global_position
	flight_duration=FLIGHT_TIME
	duration=0.45+flight_duration
	orb.position=launch_offset+Vector2(0,-65)
	orb.visible=true
	sprite.visible=false
	queue_redraw()
func _ready()->void:
	super._ready()
	orb.texture=orb_frames[0]
	orb.scale=Vector2.ONE*0.13
	orb.centered=false
	orb.offset=Vector2(-275,-140)
	orb.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	orb.visible=flight_duration>0
	add_child(orb)
func impact()->void:
	if impacted:return
	impacted=true
	if is_instance_valid(map):
		for student in map.get_students():
			if is_instance_valid(student) and student.is_targetable() and student.global_position.distance_to(global_position)<=hit_radius:
				student.apply_slow(hit_duration,hit_strength,"science")
				student.drop_frames=Presentation.science_orb_frames()
				student.slow_indicator.texture=student.drop_frames[0]
				student.slow_indicator.scale=Vector2.ONE*0.06
				if source_stats:
					source_stats.add("hits")
					source_stats.add("slows")
					source_stats.teach(student,hit_knowledge)
				else: student.teach(hit_knowledge)
	landed.emit()
func advance(delta:float)->void:
	if is_queued_for_deletion():return
	if is_instance_valid(map) and is_instance_valid(map.get_parent().get("game")) and map.get_parent().get("game").finished:
		queue_free();return
	elapsed+=delta
	if flight_duration>0 and elapsed>=flight_duration:impact()
	if elapsed>=duration:
		set_process(false);queue_free();return
	if elapsed<flight_duration:
		var t:=elapsed/flight_duration
		ground_position=launch_offset.lerp(Vector2.ZERO,t)
		orb.position=ground_position+Vector2(0,-65*(1-t)-4*ARC_HEIGHT*t*(1-t))
		orb.texture=orb_frames[mini(3,int(t*4))]
		queue_redraw()
		return
	orb.visible=false
	sprite.visible=true
	queue_redraw()
	var impact_time:=elapsed-flight_duration
	sprite.texture=frames[mini(4,int(impact_time/0.45*5))]
	sprite.modulate.a=minf(1.0,(duration-elapsed)/0.08)
func _draw()->void:
	if flight_duration>0 and elapsed<flight_duration:
		draw_set_transform(ground_position,0,Vector2(1,0.35))
		draw_circle(Vector2.ZERO,12,Color(0.03,0.08,0.09,0.28))
