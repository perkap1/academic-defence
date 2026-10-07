extends RefCounted
const Atlas = preload("res://scripts/tower_presentation.gd")
# Headers and grid borders are excluded. Every state uses the same foot canvas.
const STATES := [Vector2(66,422),Vector2(434,762),Vector2(775,1094),Vector2(1108,1437)]
const IDLE_ROWS := [Vector2(136,305),Vector2(480,642),Vector2(812,949)]
const WALK_ROWS := [Vector2(307,462),Vector2(654,796),Vector2(956,1072)]
const IDLE_CENTERS := [[128,244],[495,613],[835,951],[1176,1294]]
const WALK_CENTERS := [[108,197,285,374],[476,560,643,721],[815,896,980,1058],[1151,1236,1316,1392]]
static func create(books: int) -> Dictionary:
	var state: int = clampi(3-books,0,3)
	var sheet: Texture2D = load("res://assets/bookworm/bookworm_sheet.png")
	var result := {}
	for direction_index in range(3):
		var direction: String = ["front","side","back"][direction_index]
		var list := []
		for i in range(6):
			var idle: bool = i < 2
			var centers: Array = IDLE_CENTERS[state] if idle else WALK_CENTERS[state]
			var frame_index: int = i if idle else i-2
			var center: float = centers[frame_index]
			var left: float = STATES[state].x if frame_index==0 else floorf((centers[frame_index-1]+center)*0.5)
			var right: float = STATES[state].y if frame_index==centers.size()-1 else floorf((center+centers[frame_index+1])*0.5)
			if idle: right = minf(right,center+61)
			if idle: left = maxf(left,center-61)
			var row: Vector2 = IDLE_ROWS[direction_index] if idle else WALK_ROWS[direction_index]
			list.append(Atlas.atlas(sheet,Rect2(left,row.x,right-left,row.y-row.x),Vector2(center,row.y),Vector2(180,200),Vector2(90,190)))
		result[direction] = list
	return result
static func reaction_frames() -> Array:
	var sheet: Texture2D = load("res://assets/bookworm/reaction_sheet.png")
	var regions := [Rect2(114,844,246,223),Rect2(416,844,264,223),Rect2(713,844,266,223),Rect2(1028,844,288,223)]
	var result := []
	for region in regions:
		result.append(Atlas.atlas(sheet,region,Vector2(region.get_center().x,1067),Vector2(320,250),Vector2(160,225)))
	return result
