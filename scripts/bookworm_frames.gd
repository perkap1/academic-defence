extends RefCounted
const Atlas = preload("res://scripts/tower_presentation.gd")
# Two idle and four distinct walk poses. The extra closing walk pose in
# the supplied sheet is omitted; headers, labels and borders stay outside.
const ROWS = [[Vector2(44,141),Vector2(145,242),Vector2(246,340)],
	[Vector2(391,490),Vector2(493,590),Vector2(593,687)],
	[Vector2(741,840),Vector2(843,939),Vector2(944,1039)],
	[Vector2(1091,1188),Vector2(1191,1288),Vector2(1292,1389)]]
static func create(books: int) -> Dictionary:
	var state = clampi(3-books,0,3)
	var sheet: Texture2D = load("res://assets/enemies_v014/bookworm.png")
	var result = {}
	var centers = [414,514,617,719,820,921]
	var bounds = [363,465,565,668,770,871,971]
	for row in range(3):
		var list = []
		var span: Vector2 = ROWS[state][row]
		for i in range(6):
			list.append(Atlas.atlas(sheet,Rect2(bounds[i],span.x,bounds[i+1]-bounds[i],span.y-span.x),Vector2(centers[i],span.y-2),Vector2(180,200),Vector2(90,190)))
		result[["front","side","back"][row]]=list
	return result
static func reaction_frames() -> Array:
	var sheet: Texture2D = load("res://assets/bookworm/reaction_sheet.png")
	var regions := [Rect2(114,844,246,223),Rect2(416,844,264,223),Rect2(713,844,266,223),Rect2(1028,844,288,223)]
	var result := []
	for region in regions:
		result.append(Atlas.atlas(sheet,region,Vector2(region.get_center().x,1067),Vector2(320,250),Vector2(160,225)))
	return result
