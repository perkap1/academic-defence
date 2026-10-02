extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  print("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.game.TOWER_COSTS.get("assistant",0)==120,"Assistant costs120")
 if not main.game.TOWER_COSTS.has("assistant"):
  print("V006: %d checks, %d failures" % [checks,failures])
  main.free()
  quit(1)
  return
 var slot=main.map.slots.get_child(2)
 main.build(slot,"assistant")
 var post=slot.tower
 check(post.assistants.size()==2 and main.game.gold==80,"Post creates exactly two assistants")
 check(post.global_position.distance_to(post.rally_point)<=post.teaching_range,"Auto rally within range")
 for a in post.assistants:
  a._process(3)
 check(post.assistants[0].global_position.distance_to(post.assistants[1].global_position)>20,"Distinct home positions")
 var original:Vector2=post.rally_point
 check(not post.try_move_rally(Vector2(-900,-900)) and post.rally_point==original,"Reject distant/off-road rally without moving")
 var edge:Vector2=original
 for offset in range(0,int(main.map.route.curve.get_baked_length()),3):
  var candidate:Vector2=main.map.route.to_global(main.map.route.curve.sample_baked(offset))
  if candidate.distance_to(post.global_position)>242 and candidate.distance_to(post.global_position)<250:
   edge=candidate
   break
 check(post.try_move_rally(edge),"Rally allowed in outer displayed260radius")
 post.try_move_rally(original)
 var next:Vector2=main.map.route.to_global(main.map.route.curve.sample_baked(main.map.route.curve.get_closest_offset(main.map.route.to_local(original))+25))
 check(post.try_move_rally(next+Vector2(0,10)) and post.rally_point.distance_to(next)<11,"Manual rally snaps to nearby road")
 for a in post.assistants: a._process(3)
 main.select_slot(slot)
 check(post.marker.visible and post.show_range,"Selection shows rally and ranges")
 check(main.ui.sell_button.text.contains("60"),"Assistant selection offers60refund")
 main.clear_selection()
 check(not post.marker.visible,"Deselection hides marker")
 main.select_slot(main.map.slots.get_child(0))
 check(main.ui.assistant_button.disabled,"Assistant disabled with80KP")
 main.ui.close_build_menu()
 var students=[]
 for i in range(3):
  var s=load("res://scenes/student.tscn").instantiate()
  s.configure("normal" if i==0 else "pe","girl" if i==2 else "boy")
  main.map.route.add_child(s)
  s.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))+i*10
  students.append(s)
 for a in post.assistants: a._process(0.01)
 check(students[0].teacher!=null and students[1].teacher!=null and students[2].teacher==null,"Two exclusive reservations; third unblocked")
 for a in post.assistants: a._process(1)
 check(students[0].assistant_hold and students[1].assistant_hold,"Both assistants begin teaching")
 for s in students:
  var before:float=s.progress
  s._process(0.5)
  check(is_equal_approx(before,s.progress)==(s!=students[2]),"Only teaching students stop")
 check(not students[0].reserve_teacher(post.assistants[1]),"A second assistant cannot claim held student")
 students[0].apply_slow()
 students[0]._process(2.1)
 check(students[0].assistant_hold and students[0].speed==students[0].base_speed and not students[0].slow_indicator.visible,"Slow expires during hold without releasing student")
 for a in post.assistants: a._process(1)
 check(students[0].knowledge==5 and students[1].knowledge==5,"5 knowledge per second")
 for a in post.assistants: a._process(2.5)
 check(students[0].knowledge==15 and students[1].knowledge==15,"Full teaching capped at15 even on long frame")
 for s in students.slice(0,2):
  check(s.teacher==null and not s.assistant_hold,"Released after3seconds")
  var before:float=s.progress
  s._process(0.1)
  check(s.progress>before,"Student resumes movement")
 for a in post.assistants:
  a._process(4)
  check(a.global_position.distance_to(a.home_position())<1,"Assistant returns home")
 # Remove pass-through student so completion check uses controlled single target.
 for s in students: s.free()
 var s=load("res://scenes/student.tscn").instantiate()
 s.configure("pe","girl")
 main.map.route.add_child(s)
 s.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))
 s.resolved.connect(main.student_resolved)
 s.knowledge=99
 var a=post.assistants[0]
 a.cooldown=0
 a._process(0.01)
 a._process(1)
 a._process(0.2)
 check(s.done and a.target==null and not s.assistant_hold,"Graduation immediately ends teaching")
 check(main.map.effects.get_child_count()>0,"Existing graduation effect used")
 var held=load("res://scenes/student.tscn").instantiate()
 main.map.route.add_child(held)
 held.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))
 a.global_position=a.home_position()
 a.state="idle"
 a.cooldown=0
 a._process(0.01)
 a._process(1)
 check(held.assistant_hold,"Sale test student held")
 check(main.sell(slot) and main.game.gold==150,"Sale refunds60 plus10graduation")
 check(held.teacher==null and not held.assistant_hold,"Sale immediately releases student")
 check(main.map.towers.get_child_count()==0,"Sale removes post and assistants")
 main.free()
 for kind in ["normal","pe"]:
  for sex in ["boy","girl"]:
   main=load("res://scenes/main_map2.tscn").instantiate()
   root.add_child(main)
   main.process_mode=Node.PROCESS_MODE_DISABLED
   main.build(main.map.slots.get_child(2),"assistant")
   post=main.map.slots.get_child(2).tower
   for worker in post.assistants: worker._process(3)
   var pupil=load("res://scenes/student.tscn").instantiate()
   pupil.configure(kind,sex)
   main.map.route.add_child(pupil)
   pupil.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))
   var worker=post.assistants[0]
   worker._process(.01)
   worker._process(1)
   var before:float=pupil.progress
   worker._process(2.99)
   pupil._process(2.99)
   check(pupil.assistant_hold and pupil.progress==before and pupil.knowledge==14,"All variants held equally until3seconds")
   worker._process(.01)
   check(not pupil.assistant_hold and pupil.knowledge==15,"All variants released at3seconds with15knowledge")
   pupil._process(.1)
   check(is_equal_approx(pupil.progress-before,pupil.base_speed*.1),"All variants resume own base speed")
   main.free()
 for kind in ["normal","pe"]:
  for sex in ["boy","girl"]:
   main=load("res://scenes/main_map2.tscn").instantiate()
   root.add_child(main)
   main.process_mode=Node.PROCESS_MODE_DISABLED
   main.build(main.map.slots.get_child(2),"assistant")
   post=main.map.slots.get_child(2).tower
   for worker in post.assistants: worker._process(3)
   var moving=load("res://scenes/student.tscn").instantiate()
   moving.configure(kind,sex)
   main.map.route.add_child(moving)
   moving.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))-85
   var held_frames:=0
   var released:=false
   for step in range(300):
    moving._process(.02)
    for worker in post.assistants: worker._process(.02)
    if moving.assistant_hold: held_frames+=1
    if held_frames>0 and not moving.assistant_hold:
     released=true
     break
   check(released and held_frames>=149 and held_frames<=151,"Moving normal/PE reached, held3sec and released")
   check(moving.knowledge==15,"Moving pupil receives15Knowledge")
   main.free()
 print("V006: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)

