extends "res://scripts/map1.gd"

func _ready() -> void:
	level_id = 2
	level_title = "Elvesvingene"
	build_positions = [Vector2(588,248),Vector2(406,382),Vector2(608,558),Vector2(950,541),Vector2(985,323),Vector2(1204,483),Vector2(1459,413),Vector2(1389,615)]
	route_points = [Vector2(-60,294),Vector2(100,294),Vector2(193,294),Vector2(240,313),Vector2(267,365),Vector2(288,422),Vector2(341,459),Vector2(425,473),Vector2(510,461),Vector2(574,427),Vector2(616,363),Vector2(660,308),Vector2(711,284),Vector2(768,279),Vector2(818,300),Vector2(845,347),Vector2(866,396),Vector2(910,424),Vector2(986,446),Vector2(1061,462),Vector2(1106,492),Vector2(1128,541),Vector2(1160,570),Vector2(1213,579),Vector2(1260,564),Vector2(1302,531),Vector2(1358,511),Vector2(1419,513),Vector2(1475,531),Vector2(1510,537),Vector2(1600,549),Vector2(1730,549)]
	super._ready()
