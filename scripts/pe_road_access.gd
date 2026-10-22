extends RefCounted
# PE Teacher uses every build slot on the current map. Occupancy, clearing
# and affordability are enforced by the normal construction system.
static func can_build(map,slot)->bool:
 return is_instance_valid(map) and is_instance_valid(slot) and slot.get_parent()==map.slots
