extends "res://tests/test_integration.gd"
func run():
 for map_id in range(1,6):
  var main=load("res://scenes/%s.tscn"%("main" if map_id==1 else "main_map%d"%map_id)).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for w in range(1,main.waves.counts.size()+1):
   var expected=(0 if w<3 else (1 if w<9 else (2 if w<15 else 3))) if map_id==3 else (([1,1,2,2,3][w-13] if w>=13 else 0) if map_id==4 else ((1+int((w-8)/4) if w<20 else 4) if map_id==5 and w>=8 else 0))
   var plan=main.waves.get_spawn_plan(w);var amount=0
   for index in range(plan.size()):
    var record=plan[index]
    if record.kind=="clown":amount+=1
    check(record.route==main.waves.get_spawn_route(index,w),"Plan uses actual route")
   check(amount==expected,"Approved Class Clown count map%d wave%d"%[map_id,w])
   check(plan.size()==main.waves.counts[w-1],"Original total unchanged")
   main.waves.wave=w-1;main.update_ui()
   var preview=main.waves.get_next_wave_preview();var preview_count=0
   for entry in preview:preview_count+=preview[entry].get("clown",0)
   check(preview_count==amount,"Exact clown preview across active entries")
  main.free()
 print("CLOWN WAVES: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
