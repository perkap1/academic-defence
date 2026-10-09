extends RefCounted
const VARIANTS := ["school_books","school_trash","nature_planks","nature_logs","stone_rocks","stone_rubble"]
# Fixed indices, zero-based. Central opening strategies remain available.
const LAYOUTS := {
	1: {0:"school_books",3:"nature_planks",8:"stone_rocks"},
	2: {0:"school_trash",4:"nature_logs",7:"stone_rubble"},
	3: {0:"school_books",5:"stone_rubble",9:"nature_logs",12:"school_trash",13:"stone_rocks"},
	4: {0:"school_trash",4:"nature_logs",6:"stone_rocks",11:"nature_planks",13:"stone_rubble"}
}
static func cost(variant: String) -> int:
	if variant.begins_with("school_"): return 30
	if variant.begins_with("nature_"): return 50
	if variant.begins_with("stone_"): return 70
	return 0
static func texture(variant: String, hover: bool) -> Texture2D:
	return load("res://assets/blockers/%s_%s.png" % [variant,"hover" if hover else "normal"])
