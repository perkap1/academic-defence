extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var paths=main.map.get_routes()
 check(paths.size()==2,"Exactly two confirmed left entrances")
 check(main.map.slots.get_child_count()==16,"All sixteen visible circles")
 for path in paths:
  var curve:Curve2D=path.curve
  check(curve.get_point_position(0).x<0,"Starts outside left edge")
  check(curve.sample_baked(100).x>curve.sample_baked(0).x,"Enters moving right")
 check(paths[0].curve.get_point_position(paths[0].curve.point_count-1).x>1672,"Upper exits right")
 check(paths[1].curve.get_point_position(paths[1].curve.point_count-1).y<0,"Lower exits top")
 for point in [Vector2(930,490),Vector2(914,375),Vector2(844,100)]:
  check(paths[1].curve.get_closest_point(point).distance_to(point)<20,"Lower follows tunnel and top road")
 check(main.map.has_node("TunnelForeground"),"Tunnel arch occludes lower units")
 main.free();print("MAP3 REPLACEMENT: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
