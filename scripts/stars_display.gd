extends Control
const GREY = preload("res://assets/stars/grey.png")
const GOLD = preload("res://assets/stars/gold.png")
const SHINE = preload("res://assets/stars/shine.png")
var stars := []
var earned := 0
var sequence: Tween
func configure(rating: int, animate: bool = false, star_size: float = 60.0) -> void:
	if sequence: sequence.kill()
	for item in stars: item.queue_free()
	stars.clear()
	earned = clampi(rating,0,3)
	size = Vector2(star_size*3,star_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in range(3):
		var star := TextureRect.new()
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.size = Vector2.ONE*star_size
		star.position.x = i*star_size
		star.pivot_offset = star.size/2
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.texture = GREY if animate or i >= earned else GOLD
		add_child(star)
		stars.append(star)
	if animate:
		sequence = create_tween()
		for i in range(earned):
			var star: TextureRect = stars[i]
			sequence.tween_interval(0.20)
			sequence.tween_callback(func(): star.texture=SHINE)
			sequence.tween_property(star,"scale",Vector2.ONE*1.16,0.12).set_trans(Tween.TRANS_BACK)
			sequence.tween_property(star,"scale",Vector2.ONE,0.13)
			sequence.tween_callback(func(): star.texture=GOLD)
