extends RefCounted
# Reviewed against the original map art: these slots have an unobstructed
# corridor to the adjacent road. Distance is also checked against the live path,
# so moving a slot away from that road cannot inherit permission.
const MAX_DISTANCE:=110.0
const CLEAR_CORRIDORS:={
 1:[0,4,6],
 2:[0,1,3,5,6,7],
 3:[0,1,2,3,4,6,7,8,9,10,11,12,13,14,15],
 4:[2,3,4,5,8,11],
 5:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,17,18,19,20]
}
static func can_build(map,slot)->bool:
 if not is_instance_valid(map) or not is_instance_valid(slot) or slot.get_parent()!=map.slots:return false
 if slot.get_index() not in CLEAR_CORRIDORS.get(map.level_id,[]):return false
 var expected:Vector2=map.build_positions[slot.get_index()]
 if slot.position.distance_to(expected)>1.0:return false
 return slot.global_position.distance_to(map.nearest_road_point(slot.global_position))<=MAX_DISTANCE
