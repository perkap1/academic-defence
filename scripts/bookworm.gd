extends "res://scripts/student.gd"
const BookwormFrames = preload("res://scripts/bookworm_frames.gd")
const HitReaction = preload("res://scripts/bookworm_hit_effect.gd")
var books := 3
func configure(_kind: String = "bookworm", _sex: String = "boy") -> void:
	super.configure("normal","boy")
	student_type = "bookworm"
func _ready() -> void:
	configure()
	super._ready()
	sprite.centered = false
	sprite.offset = Vector2(-90,-190)
	sprite.position = Vector2(0,-3)
	sprite.scale = Vector2.ONE*0.73
	update_shield_art()
func update_shield_art() -> void:
	frames = BookwormFrames.create(books)
	var frame: int = animation_frame()
	sprite.texture = frames[direction][frame]
func teach(amount: int) -> void:
	if done or amount <= 0: return
	if books > 0:
		books -= 1
		var effect := HitReaction.new()
		var level = get_parent().get_parent()
		level.effects.add_child(effect)
		effect.global_position = global_position
		update_shield_art()
		return
	super.teach(amount)
