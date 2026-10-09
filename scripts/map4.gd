extends "res://scripts/map1.gd"
const UPPER:=[Vector2(-60,222),Vector2(60,222),Vector2(155,225),Vector2(225,257),Vector2(292,289),Vector2(350,290),Vector2(425,261),Vector2(480,237),Vector2(530,232),Vector2(585,255),Vector2(652,295),Vector2(700,309),Vector2(752,303),Vector2(807,281),Vector2(853,277),Vector2(902,303),Vector2(961,347),Vector2(1017,369),Vector2(1070,369),Vector2(1132,346),Vector2(1200,306),Vector2(1255,277),Vector2(1302,270),Vector2(1350,290),Vector2(1398,335),Vector2(1444,364),Vector2(1490,371),Vector2(1570,371),Vector2(1730,371)]
const LOWER:=[Vector2(-60,523),Vector2(70,523),Vector2(170,528),Vector2(239,526),Vector2(303,506),Vector2(372,477),Vector2(430,463),Vector2(482,467),Vector2(543,491),Vector2(606,527),Vector2(665,555),Vector2(716,560),Vector2(771,546),Vector2(824,542),Vector2(877,563),Vector2(934,598),Vector2(986,610),Vector2(1035,596),Vector2(1099,562),Vector2(1160,535),Vector2(1220,520),Vector2(1273,520),Vector2(1324,539),Vector2(1375,575),Vector2(1426,607),Vector2(1478,626),Vector2(1560,631),Vector2(1730,631)]
const SLOTS:=[Vector2(333,169),Vector2(691,169),Vector2(996,249),Vector2(1154,212),Vector2(1469,258),Vector2(519,340),Vector2(789,419),Vector2(922,456),Vector2(1282,376),Vector2(334,614),Vector2(577,650),Vector2(805,650),Vector2(1171,663),Vector2(1383,719)]
@onready var lower_route:Path2D=$LowerPath
func _ready()->void:
 level_id=4
 level_title="Autumn Campus"
 build_positions=SLOTS
 route_points=UPPER
 super._ready()
 route.set_meta("entrance","upper")
 lower_route.curve=create_route_curve(LOWER)
 lower_route.set_meta("entrance","lower")
func get_routes()->Array:return [route,lower_route]
