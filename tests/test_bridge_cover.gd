extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for kind in ["normal","pe","bookworm","snack","pilot","clown"]:
  var scene="class_clown" if kind=="clown" else ("paper_plane_pilot" if kind=="pilot" else ("bookworm" if kind=="bookworm" else ("snack_monster" if kind=="snack" else "student")))
  var unit=load("res://scenes/%s.tscn"%scene).instantiate();unit.configure(kind);main.map.lower_route.add_child(unit);unit.lane_offset=0
  for point in [Vector2(930,490),Vector2(920,440),Vector2(912,300)]:
   unit.progress=main.map.lower_route.curve.get_closest_offset(point);unit.update_lane_position()
   var covered=point.y==440 and kind!="pilot"
   check(unit.visible==not covered,"Hidden only beneath solid bridge, never in shadow or in flight")
   check(unit.can_receive_attack("book")==not covered,"Book targeting respects bridge and pilot flight")
   if covered:
    var before:int=unit.knowledge;var books:int=unit.get("books") if kind=="bookworm" else 0
    unit.receive_attack(20,"book");unit.teach(20)
    check(unit.knowledge==before and (kind!="bookworm" or unit.books==books),"Protected from in-flight hits and shield loss")
  unit.free()
 main.free();print("BRIDGE COVER: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
