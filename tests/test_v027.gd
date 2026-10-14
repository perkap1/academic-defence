extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.waves.has_method("get_spawn_plan"),"Prepared plan includes exact PE variants")
 if not main.waves.has_method("get_spawn_plan"):main.free();finish();return
 for scene in ["main","main_map2","main_map3","main_map4","main_map5"]:
  var level=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(level);level.process_mode=Node.PROCESS_MODE_DISABLED
  for w in range(1,level.waves.counts.size()+1):
   level.waves.wave=w-1;level.waves.active=false;level.update_ui()
   var plan:Array=level.waves.get_spawn_plan(w)
   check(plan==level.waves.get_spawn_plan(w),"Preview does not reroll cached variants")
   var expected={}
   for record in plan:
    var kind:String=record.kind
    if kind=="pe":kind="pe_"+record.variant
    if not expected.has(record.route):expected[record.route]={}
    expected[record.route][kind]=expected[record.route].get(kind,0)+1
   check(expected==level.wave_preview.composition,"Exact six-variant UI by entrance")
   for entry in level.wave_preview.icons:
    var icon=level.wave_preview.icons[entry];var center:Vector2=icon.position+icon.size/2
    check(center.distance_to(level.map.nearest_road_point(center))<1.0,"Warning exactly on road center")
    check(icon.has_method("get_visual_frame"),"Warning uses supplied animated artwork")
   level.waves.start_wave();level.waves._process(500)
   check(level.waves.students.size()==plan.size(),"Entire planned wave spawns including batches")
   for i in range(plan.size()):
    var unit=level.waves.students[i]
    check(unit.student_type==plan[i].kind and (unit.student_type!="pe" or unit.variant==plan[i].variant),"Actual variant matches preview")
    check(unit.get_parent()==level.map.get_routes()[plan[i].route],"Actual entrance matches preview")
    unit.free()
   level.waves.students.clear();level.waves.active=false
  level.free()
 for kind in main.wave_preview.KINDS:
  check(main.wave_preview.enemy_texture(kind).get_size()==Vector2(16,16),"Original mini artwork normalized to tiny canvas")
 var icon=main.wave_preview.icons.values()[0]
 for frame in range(4):
  icon.hover_preview=false;icon.elapsed=frame*0.25
  check(icon.get_visual_frame()==frame,"Four idle frames at calm four FPS")
 icon.hover_preview=true
 check(icon.get_visual_frame()==4,"Dedicated golden hover pose")
 await process_frame
 main.wave_preview.show_entry(0)
 var motion=InputEventMouseMotion.new();motion.position=root.get_final_transform()*main.wave_preview.panel.get_global_rect().get_center();motion.global_position=motion.position
 Input.parse_input_event(motion);await process_frame
 main.wave_preview._process(0.3)
 check(main.wave_preview.panel.visible,"Moving into panel retains hover information")
 main.free();finish()
func finish():
 print("V027: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
