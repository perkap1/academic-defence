extends Node2D
# Fixed 3x5 gold pixel glyph, drawn over the stable tower banner.
const GLYPHS=["010110010010111","110001010100111","110001010001110"]
func _ready()->void:
	if get_parent().tower_type=="book":position.y=6.3
func _draw()->void:
	if get_parent().tower_type=="book":
		# Keep the level readable over the supplied banner's decorative emblem.
		draw_rect(Rect2(-18,-48,36,26),Color("a31b2b"))
	var bits:String=GLYPHS[get_parent().level-1]
	for y in range(5):
		for x in range(3):
			if bits[y*3+x]=="1":
				var point=Vector2(-6+x*4,-44+y*4)
				draw_rect(Rect2(point+Vector2(1,1),Vector2(4,4)),Color("674016"))
				draw_rect(Rect2(point,Vector2(4,4)),Color("ffd15a"))
