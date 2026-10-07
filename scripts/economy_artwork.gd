extends RefCounted
# Original 4x5 sheet; transparent gutters differ between rows/columns.
const CELLS := [0,330,624,915,1208,1536]
const ROWS := [Vector2(0,244),Vector2(251,501),Vector2(505,748),Vector2(748,1024)]
const PIVOTS := [[184.5,482,770,1062,1358.5],[180.5,477.5,765.5,1060.5,1357],[183,478.5,769,1061.5,1352.5],[182,479,768.5,1058.5,1361]]
const FEET := [243,499,742,999]
static func frames(branch: String) -> Array:
	var row_index: int = ["study","library","scholarship","research"].find(branch)
	var sheet: Texture2D = load("res://assets/economy/economy_sheet.png")
	var row: Vector2 = ROWS[row_index]
	var result := []
	for i in range(5):
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(CELLS[i],row.x,CELLS[i+1]-CELLS[i],row.y-row.x)
		frame.margin = Rect2(Vector2(180,290)-Vector2(PIVOTS[row_index][i]-CELLS[i],FEET[row_index]-row.x),Vector2(360,320)-frame.region.size)
		frame.filter_clip = true
		result.append(frame)
	return result
