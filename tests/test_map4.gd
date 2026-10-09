extends "res://tests/test_bookworm.gd"
func run():
 check(FileAccess.file_exists("res://scenes/main_map4.tscn"),"Map4 scene exists")
 if not FileAccess.file_exists("res://scenes/main_map4.tscn"):
  print("MAP4: %d checks, %d failures"%[checks,failures]);quit(1);return
 var main=load("res://scenes/main_map4.tscn").instantiate()
 root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.map.level_id==4 and main.map.slots.get_child_count()==14,"Autumn Campus has fourteen slots")
 check(main.map.get_routes().size()==2,"Two separate routes")
 check(main.waves.counts.size()==17,"Exactly seventeen waves")
 var routes=main.map.get_routes()
 var image=main.map.get_node("Background").texture.get_image()
 for route in routes:
  for distance in range(150,int(route.curve.get_baked_length())-170,12):
   for lane in [-24,0,24]:
    var point=load("res://scripts/unit_layout.gd").lane_position(route.curve,distance,lane)
    var color=image.get_pixelv(Vector2i(point.round()))
    check(color.r>color.g and color.g>color.b and color.r>0.66 and color.g>0.39,"Sand at %s color %s"%[point,color])
 check(main.waves.bookworm_counts.reduce(func(a,b):return a+b,0)>130,"More Bookworms than Map3")
 check(main.waves.snack_counts.reduce(func(a,b):return a+b,0)>32,"More Snacks than Map3")
 check(routes[0].curve.get_point_position(0).y<routes[1].curve.get_point_position(0).y,"Separate entrances")
 check(routes[0].curve.get_point_position(routes[0].curve.point_count-1).y<routes[1].curve.get_point_position(routes[1].curve.point_count-1).y,"Separate exits")
 for w in range(17):
  main.waves.wave=w;main.waves.active=false
  main.waves.start_wave();main.waves._process(200)
  var upper=routes[0].get_child_count();var lower=routes[1].get_child_count()
  check((upper>0 and lower==0) if w+1 in [3,9,15] else ((lower>0 and upper==0) if w+1 in [6,12] else (upper>0 and lower>0)),"Correct route allocation wave %d"%(w+1))
  check(main.waves.students.size()==main.waves.counts[w],"Every enemy spawned")
  for s in main.waves.students:s.free()
  main.waves.students.clear()
 var progress=root.get_node("Progression")
 progress.completed_levels.clear()
 var world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 check(not world.can_open_level(3) and world.can_open_level(2),"Map4 locked, Map3 open")
 progress.complete_level(3)
 check(world.can_open_level(3) and not world.can_open_level(4),"Map3 completion unlocks only Map4")
 var temporary=load("res://scripts/progression.gd").new()
 temporary.save_path="user://map4_regression_only.cfg"
 temporary.complete_level(3);temporary.complete_level(4)
 var restored=load("res://scripts/progression.gd").new()
 restored.save_path=temporary.save_path;restored.load_progress()
 check(3 in restored.completed_levels and 4 in restored.completed_levels,"Map4 completion survives save reload")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary.save_path))
 temporary.free();restored.free()
 world.free();main.free()
 print("MAP4: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
