extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map2.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.map.get_routes().size()==2,"Map2 has Left and Top routes")
 check(main.map.slots.get_child_count()==8,"Eight original visible building circles")
 for wave in range(1,13):
  main.waves.wave=wave-1;main.update_ui()
  var expected=[1] if wave in [3,6,9] else ([0] if wave in [1,5] else [0,1])
  var plan=main.waves.get_spawn_plan(wave);var entries=[]
  for record in plan:
   check(record.kind!="pilot","No pilots on Map2")
   check(record.route in expected,"Required entrance for every student")
   if record.route not in entries:entries.append(record.route)
  entries.sort();check(entries==expected,"Exact active entrances")
  check(main.wave_preview.icons.size()==expected.size(),"Warning icons match actual spawn plan")
  for icon in main.wave_preview.icons.values():
   check(not main.ui.instruction_panel.get_global_rect().intersects(icon.get_global_rect()),"Instruction banner clears both road warnings")
 if main.map.get_routes().size()==2:
  var paths=main.map.get_routes()
  check(paths[1].curve.get_baked_length()<paths[0].curve.get_baked_length(),"Top path shorter")
  check(paths[0].curve.get_point_position(paths[0].curve.point_count-1)==paths[1].curve.get_point_position(paths[1].curve.point_count-1),"Same exit")
  for i in range(3,paths[1].curve.point_count-1):
   var p:Vector2=paths[1].curve.get_point_position(i)
   var next:Vector2=paths[1].curve.get_point_position(i+1)
   var midpoint=p.bezier_interpolate(p+paths[1].curve.get_point_out(i),next+paths[1].curve.get_point_in(i+1),next,0.5)
   check(paths[0].curve.get_closest_point(midpoint).distance_to(midpoint)<1,"Shared outgoing segments exactly match")
  var snack=load("res://scenes/snack_monster.tscn").instantiate();snack.configure("snack","boy");paths[1].add_child(snack);snack.progress=150
  snack.teach(200);var stopped:float=snack.progress;snack._process(0.5)
  check(snack.progress==stopped and snack.get_parent()==paths[1],"Snack eats on its Top Path")
  snack._process(2);snack._process(0.5)
  check(snack.progress>stopped and snack.get_parent()==paths[1],"Snack resumes same path after eating")
  snack.free()
 main.free();print("MAP2 ENTRIES: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
