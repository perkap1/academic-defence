extends "res://scripts/map1.gd"
const COMMON := [Vector2(860,466),Vector2(960,467),Vector2(1140,467),Vector2(1400,468),Vector2(1600,470),Vector2(1730,470)]
const UPPER := [Vector2(-60,85),Vector2(25,85),Vector2(85,114),Vector2(129,175),Vector2(220,213),Vector2(354,244),Vector2(477,263),Vector2(573,263),Vector2(645,307),Vector2(708,359),Vector2(784,408)]
const LOWER := [Vector2(-60,795),Vector2(24,794),Vector2(78,758),Vector2(127,715),Vector2(210,689),Vector2(310,668),Vector2(429,631),Vector2(535,628),Vector2(612,612),Vector2(672,566),Vector2(771,515)]
@onready var lower_route: Path2D = $LowerPath
func _ready() -> void:
	level_id = 3
	level_title = "Bokruinene"
	build_positions = [Vector2(290,130),Vector2(461,192),Vector2(712,255),Vector2(546,336),Vector2(963,389),Vector2(1334,395),Vector2(546,548),Vector2(963,548),Vector2(1334,548),Vector2(711,641),Vector2(453,700),Vector2(223,749),Vector2(1148,393),Vector2(1148,550)]
	route_points = UPPER + COMMON
	super._ready()
	route.set_meta("entrance","upper")
	lower_route.curve = create_route_curve(LOWER + COMMON)
	lower_route.set_meta("entrance","lower")
func get_routes() -> Array: return [route,lower_route]
func create_route_curve(points: Array) -> Curve2D:
	var curve: Curve2D = super.create_route_curve(points)
	# Both curves have identical outgoing handles from the join onward.
	var join_index: int = points.find(COMMON[0])
	curve.set_point_out(join_index,Vector2(25,0))
	return curve
