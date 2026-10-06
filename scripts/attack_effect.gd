extends Node2D

var effect_level := 0
var kind := "sponge_swipe"
var frame_count := 5
var duration := 0.45
var elapsed := 0.0
var frames := []
var sprite := Sprite2D.new()

func configure(effect_kind: String, count: int, seconds: float) -> void:
	kind = effect_kind
	frame_count = count
	duration = seconds

func configure_blackboard(level:int)->void:
	configure("sponge_swipe",5,0.45)
	effect_level=level
	frames=preload("res://scripts/tower_presentation.gd").sponge_frames(level)

func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	if frames.is_empty():
		for i in range(frame_count):
			frames.append(load("res://assets/effects/%s_%d.png" % [kind,i]))
	sprite.texture = frames[0]
	add_child(sprite)

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if is_queued_for_deletion(): return
	elapsed += delta
	if elapsed >= duration:
		set_process(false)
		queue_free()
		return
	sprite.texture = frames[mini(frame_count-1,int(elapsed / duration * frame_count))]
	sprite.modulate.a = minf(1.0,(duration-elapsed)/0.08)
