extends Node2D
var elapsed := 0.0
var duration := 0.45
var sprite := Sprite2D.new()
var frames := []
func _ready() -> void:
	frames = preload("res://scripts/bookworm_frames.gd").reaction_frames()
	sprite.centered = false
	sprite.offset = Vector2(-160,-225)
	sprite.scale = Vector2.ONE*0.25
	sprite.position = Vector2(25,-16)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = frames[0]
	add_child(sprite)
func _process(delta: float) -> void:
	if is_queued_for_deletion(): return
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	sprite.texture = frames[mini(3,int(elapsed/duration*4))]
	sprite.modulate.a = minf(1,(duration-elapsed)/0.07)
