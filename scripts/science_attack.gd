extends "res://scripts/attack_effect.gd"
const Presentation=preload("res://scripts/tower_presentation.gd")
var orb_frames:=[]
var orb:=Sprite2D.new()
var launch_offset:=Vector2.ZERO
var flight_duration:=0.0
func configure_science(level:int,radius:float)->void:
	configure("science_cloud",5,0.45)
	effect_level=level
	frames=Presentation.science_cloud_frames()
	orb_frames=Presentation.science_orb_frames()
	sprite.scale=Vector2.ONE*(radius*2.0/360.0)
	sprite.centered=false
	sprite.offset=Vector2(-200,-330)
func launch_from(point:Vector2)->void:
	launch_offset=point-global_position
	flight_duration=0.16
	duration=0.45+flight_duration
	orb.position=launch_offset
	orb.rotation=(-launch_offset).angle()
	orb.visible=true
	sprite.visible=false
func _ready()->void:
	super._ready()
	orb.texture=orb_frames[0]
	orb.scale=Vector2.ONE*0.13
	orb.centered=false
	orb.offset=Vector2(-275,-140)
	orb.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	orb.visible=flight_duration>0
	add_child(orb)
func advance(delta:float)->void:
	if is_queued_for_deletion():return
	elapsed+=delta
	if elapsed>=duration:
		set_process(false);queue_free();return
	if elapsed<flight_duration:
		orb.position=launch_offset.lerp(Vector2.ZERO,elapsed/flight_duration)
		orb.texture=orb_frames[mini(3,int(elapsed/flight_duration*4))]
		return
	orb.visible=false
	sprite.visible=true
	var impact_time:=elapsed-flight_duration
	sprite.texture=frames[mini(4,int(impact_time/0.45*5))]
	sprite.modulate.a=minf(1.0,(duration-elapsed)/0.08)
