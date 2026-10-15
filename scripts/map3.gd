extends "res://scripts/map1.gd"
const UPPER := [Vector2(-60,237),Vector2(80,237),Vector2(210,238),Vector2(280,267),Vector2(319,324),Vector2(356,352),Vector2(444,356),Vector2(540,364),Vector2(625,389),Vector2(701,396),Vector2(801,378),Vector2(914,375),Vector2(1025,377),Vector2(1090,399),Vector2(1136,444),Vector2(1173,499),Vector2(1233,533),Vector2(1330,548),Vector2(1432,582),Vector2(1511,580),Vector2(1610,573),Vector2(1730,573)]
const LOWER := [Vector2(-60,705),Vector2(90,705),Vector2(239,711),Vector2(329,693),Vector2(430,666),Vector2(502,672),Vector2(575,712),Vector2(650,730),Vector2(799,729),Vector2(900,713),Vector2(956,675),Vector2(962,617),Vector2(943,553),Vector2(930,490),Vector2(921,431),Vector2(914,375),Vector2(912,311),Vector2(882,270),Vector2(850,231),Vector2(844,171),Vector2(844,80),Vector2(844,-60)]
@onready var lower_route: Path2D = $LowerPath
func _ready() -> void:
 level_id = 3
 level_title = "Bokruinene"
 build_positions = [Vector2(361,202),Vector2(445,273),Vector2(603,296),Vector2(740,200),Vector2(950,200),Vector2(1015,258),Vector2(225,317),Vector2(1288,466),Vector2(1423,504),Vector2(490,580),Vector2(640,618),Vector2(843,555),Vector2(1056,590),Vector2(1451,682),Vector2(268,795),Vector2(423,770)]
 route_points = UPPER
 super._ready()
 route.set_meta("entrance","upper_left")
 lower_route.curve = create_route_curve(LOWER)
 lower_route.set_meta("entrance","lower_left")
func get_routes() -> Array: return [route,lower_route]

func is_under_bridge(unit)->bool:
 if unit.student_type=="pilot" or unit.get_parent()!=lower_route:return false
 # Solid bridge/tunnel footprint; the approach shadow is outside this zone.
 return Rect2(850,335,150,115).has_point(to_local(unit.global_position))
