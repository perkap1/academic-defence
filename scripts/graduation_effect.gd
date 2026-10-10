extends Node2D

const DURATION := 0.85
var duration := DURATION
var elapsed := 0.0
var reward := 10
var frame_index := 0
var frames := []
var sprite := Sprite2D.new()

func _ready() -> void:
	add_to_group("graduation_effects")
	var label := Label.new()
	label.name = "Reward"
	label.text = "+%d KP" % reward
	label.position = Vector2(-50,-125)
	label.size = Vector2(100,28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",20)
	label.add_theme_color_override("font_color",Color("ffe58a"))
	label.add_theme_color_override("font_outline_color",Color("142b29"))
	label.add_theme_constant_override("outline_size",4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	create_tween().tween_property(label,"position:y",-150.0,DURATION)
	for i in range(9):
		frames.append(load("res://assets/effects/graduation_%d.png" % i))
	sprite.position = Vector2(0,-72)
	sprite.texture = frames[0]
	add_child(sprite)

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if is_queued_for_deletion():
		return
	elapsed += delta
	if elapsed >= duration:
		set_process(false)
		queue_free()
		return
	frame_index = mini(8,int(elapsed / duration * 9.0))
	sprite.texture = frames[frame_index]
	# Final dust frame fades rather than popping off the screen.
	sprite.modulate.a = clampf((duration-elapsed) / (duration/9.0),0,1) if frame_index == 8 else 1.0
