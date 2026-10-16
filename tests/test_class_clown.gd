extends "res://tests/test_integration.gd"
func spawn(main,kind:String,offset:float=0):
 var scene="class_clown" if kind=="clown" else ("paper_plane_pilot" if kind=="pilot" else ("bookworm" if kind=="bookworm" else ("snack_monster" if kind=="snack" else "student")))
 var unit=load("res://scenes/%s.tscn"%scene).instantiate();unit.configure(kind);unit.resolved.connect(main.student_resolved);main.map.get_routes()[0].add_child(unit);unit.progress=500+offset;unit.lane_offset=0;unit.update_lane_position();return unit
func run():
 check(FileAccess.file_exists("res://scenes/class_clown.tscn"),"Class Clown integrated scene exists")
 if not FileAccess.file_exists("res://scenes/class_clown.tscn"):quit(1);return
 var main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var clown=spawn(main,"clown");clown.teach(50)
 check(clown.get_heal_capacity()==120 and clown.base_speed==85 and clown.base_reward==10,"Approved resistance speed reward")
 for facing in ["front","side","back"]:
  for frame in range(13):
   var art=clown.frames[facing][frame]
   var used:Rect2i=art.get_image().get_used_rect()
   check(absf(used.end.y+art.margin.position.y-285)<0.01,"All live poses share exact wheel-ground origin")
 var pupils=[]
 for kind in ["normal","pe","bookworm","snack","pilot","clown"]:
  var unit=spawn(main,kind)
  if kind=="bookworm":unit.books=0;unit.update_shield_art()
  if kind=="snack":unit.teaching_points=160;unit.knowledge=40;unit.bar.value=40
  elif kind=="pilot":unit.receive_attack(60,"book")
  else:unit.teach(60)
  pupils.append(unit)
 var distant=spawn(main,"normal",500);distant.teach(50)
 clown.heal_clock=3.99;clown._process(0.01)
 check(clown.casting and clown.pulses_fired==0,"Cast starts after four active seconds")
 check(clown.predict_position(0.2).distance_to(clown.global_position)<0.01,"Science aim respects stationary cast")
 var progress_before:float=clown.progress;clown._process(0.29)
 check(clown.progress==progress_before and pupils[0].knowledge==60,"Stops and waits for confetti cast release")
 clown._process(0.02)
 check(clown.pulses_fired==1 and clown.knowledge==50,"One pulse never heals self")
 for i in range(pupils.size()):
  var unit=pupils[i];var kind:String=unit.student_type
  var expected:float=37.5 if kind=="pilot" else (25 if kind=="snack" else (42 if kind=="clown" else 45))
  check(absf(unit.knowledge-expected)<0.001,"15 percent of own maximum: %s"%kind)
 check(pupils[2].books==0,"Book shield never regrows")
 check(distant.knowledge==50,"Outside radius unchanged")
 check(pupils[4].can_receive_attack("book") and not pupils[4].can_receive_attack("blackboard"),"Pilot retains attack restrictions")
 clown._process(0.44);check(not clown.casting and clown.progress==progress_before,"Cast ends without path reset")
 clown._process(0.1);check(clown.progress>progress_before,"Movement resumes same route")
 var other=pupils[5];check(other.pulses_fired==0 and not other.casting,"Healing another clown cannot trigger chains")
 pupils[0].receive_confetti_heal(1);check(pupils[0].knowledge==0,"Cannot heal beyond full health")
 pupils[0].done=true;check(not pupils[0].receive_confetti_heal(0.15),"Cannot resurrect completed student")
 var snack=pupils[3];snack.teach(100)
 check(snack.is_eating() and snack.snack_break_used,"Snack Break still activates once")
 var eating_before:float=snack.eating_remaining;snack.receive_confetti_heal(0.15)
 check(snack.eating_remaining==eating_before and snack.snack_break_used,"Confetti never resets Snack Break")
 snack._process(2);check(snack.teaching_points==40 and snack.knowledge==10,"Own 75 percent heal and confetti benefit coexist")
 clown._process(7.5);check(clown.pulses_fired==3,"Long active steps preserve four-second cast cadence without duplicate pulses")
 main.waves.wave=10
 var gold_before:int=main.game.gold
 var resolved_count=[0];clown.resolved.connect(func(_unit,_grad):resolved_count[0]+=1)
 clown.teach(500);clown.teach(500)
 check(clown.done and clown.defeated and resolved_count[0]==1,"Comic graduation resolves exactly once")
 check(main.game.gold==gold_before+7,"Exactly one10KP reward with existing70percent taper")
 for facing in ["front","side","back"]:check(clown.frames[facing].size()==18,"Two idle four move five cast two hit five comic defeat frames")
 for unit in pupils:unit.free()
 distant.free();clown.free()
 var clock_clown=spawn(main,"clown");clock_clown.heal_clock=0
 main.process_mode=Node.PROCESS_MODE_INHERIT;main.waves.set_process(false)
 paused=true
 await create_timer(0.08,true,false,true).timeout
 check(clock_clown.heal_clock==0,"Pause freezes active heal clock")
 paused=false;Engine.time_scale=2
 await create_timer(0.08,true,false,true).timeout
 check(clock_clown.heal_clock>=0.10,"Game speed scales heal clock with gameplay")
 Engine.time_scale=1;main.free()
 print("CLASS CLOWN: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
