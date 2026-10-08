extends RefCounted
const Atlas = preload("res://scripts/tower_presentation.gd")
# Fixed source scale and foot canvas; never resize individual run poses.
static func create(variant: String) -> Dictionary:
	var sheet: Texture2D=load("res://assets/enemies_v014/pe.png")
	var result={}
	var bounds=[140,320,500,668,836,1025,1220]
	var rows=[Vector2(0,200),Vector2(200,383),Vector2(383,570),Vector2(570,760),Vector2(760,930),Vector2(930,1086)]
	var centers=[[236,407,582,742,914,1091],[229,399,568,735,901,1071],[236,408,584,755,921,1094],
		[236,410,596,772,944,1112],[228,405,620,790,955,1105],[232,407,590,759,929,1112]]
	var feet=[197,382,565,757,932,1086]
	for direction_index in range(3):
		var row=direction_index+(3 if variant=="girl" else 0)
		if variant=="girl": bounds=[140,325,505,692,853,1027,1220]
		var span: Vector2=rows[row]
		var list=[]
		for i in range(6):
			list.append(Atlas.atlas(sheet,Rect2(bounds[i],span.x,bounds[i+1]-bounds[i],span.y-span.x),Vector2(centers[row][i],feet[row]),Vector2(220,220),Vector2(110,210)))
		result[["front","side","back"][direction_index]]=list
	return result
