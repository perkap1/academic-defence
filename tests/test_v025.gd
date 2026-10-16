extends "res://tests/test_integration.gd"
func run():
 check(ResourceLoader.exists("res://scenes/main_map5.tscn"),"Final Exam scene exists")
 if not ResourceLoader.exists("res://scenes/main_map5.tscn"):finish();return
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.map.level_id==5,"Level5 identity")
 check(main.map.get_routes().size()==4,"Four independent entry paths")
 check(main.map.slots.get_child_count()==21,"Exactly21 original platforms")
 var blockers={30:0,50:0,70:0,0:0}
 for slot in main.map.slots.get_children():blockers[slot.get_clear_cost()]+=1
 check(blockers=={30:4,50:3,70:3,0:11},"4school3wood3stone11open")
 check(main.waves.counts.size()==22,"Exactly22waves")
 var routes=main.map.get_routes()
 for i in range(3):check(routes[i].curve.get_point_position(routes[i].curve.point_count-1)==Vector2(1508,311),"ABC share school exit")
 check(routes[3].curve.get_point_position(routes[3].curve.point_count-1)==Vector2(1450,652),"D ends at bridge")
 var image=main.map.get_node("Background").texture.get_image()
 check(image.get_size()==Vector2i(1672,941),"Exact original map dimensions")
 for slot in main.map.slots.get_children():
  var color=image.get_pixelv(Vector2i(slot.position))
  check(color.r>color.g and color.g>color.b and color.r>0.65,"Slot centered on existing sandy platform")
 var layout=load("res://scripts/unit_layout.gd")
 for route in routes:
  var length:float=route.curve.get_baked_length()
  for distance in range(80,int(length)-90,16):
   for lane in [-24,0,24]:
    var point:Vector2=layout.lane_position(route.curve,distance,lane)
    if point.x<10 or point.y<10 or point.y>930:continue
    var color=image.get_pixelv(Vector2i(point.round()))
    check(color.r>color.g and color.g>color.b and color.r>(0.35 if point.x<75 else 0.54),"Road or wooden bridge lane%s at %s color%s"%[lane,point,color])
 for wave in range(22):
  main.waves.wave=wave+1
  var tally={"normal":0,"pe":0,"bookworm":0,"snack":0,"pilot":0,"clown":0};var entrances={}
  for i in range(main.waves.counts[wave]):
   var kind=main.waves.get_spawn_kind(i);tally[kind]+=1
   entrances[main.waves.get_spawn_route(i)]=true
  check(tally.pe==main.waves.pe_counts[wave] and tally.bookworm==main.waves.bookworm_counts[wave] and tally.snack==main.waves.snack_counts[wave] and tally.pilot==main.waves.pilot_counts[wave],"Exact enemy mix wave%d"%(wave+1))
  if wave>=18:check(entrances.size()==4,"All entries active in final waves")
 var progress=root.get_node("Progression");progress.completed_levels.clear()
 var world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 check(not world.can_open_level(4),"Map5 locked initially")
 progress.complete_level(4);check(world.can_open_level(4),"Map4 unlocks Map5")
 progress.complete_level(5,3);check(progress.get_stars(5)==3,"Map5 stars recorded")
 var temporary=load("res://scripts/progression.gd").new();temporary.save_path="user://map5_regression_only.cfg"
 temporary.complete_level(5,2);temporary.complete_level(5,1)
 var restored=load("res://scripts/progression.gd").new();restored.save_path=temporary.save_path;restored.load_progress()
 check(5 in restored.completed_levels and restored.get_stars(5)==2,"Map5 best stars survive save and reload")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary.save_path));temporary.free();restored.free()
 world.free();main.free();finish()
func finish():
 print("V025: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
