extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for slot in main.map.slots.get_children():slot.set_blocker("")
 main.game.gold=10000
 var slot=main.map.slots.get_child(0);main.build(slot,"economy");var building=slot.tower
 main.economy.complete_wave(1);main.select_slot(slot);main.specialize(slot,"library")
 check(building.get_income()==30,"Library income reduced to30")
 main.economy.complete_wave(2)
 if building.get("stats")==null:
  check(false,"Each building owns shared statistics")
  main.free();print("V020: %d checks, %d failures"%[checks,failures]);quit(1);return
 check(building.stats.total.get("kp",0)==45 and building.stats.current().get("kp",0)==30,"Specialization preserves lifetime income")
 main.sell(slot);main.build(slot,"economy");main.select_slot(slot);main.specialize(slot,"scholarship");building=slot.tower
 check(building.get_income()==0,"Scholarship has no base income")
 main.waves.active=true;main.waves.remaining=1;main.economy.begin_wave(3)
 var students=[]
 for i in range(10):
  var student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student);student.global_position=building.global_position
  student.resolved.connect(main.student_resolved);students.append(student)
  student.teach(100)
 check(building.wave_bonus==40 and building.stats.total.get("kp",0)==40 and building.stats.total.get("rewarded",0)==8,"Office cap and actual graduation statistics")
 var before:int=main.game.gold;main.economy.complete_wave(3);check(main.game.gold==before,"Office does not pay at wave end")
 main.economy.begin_wave(4);check(building.wave_bonus==0,"Wave cap resets")
 main.sell(slot);main.build(slot,"book");var tower=slot.tower
 check(tower.get_upgrade_cost()==100,"Book level2 remains100")
 var student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student);student.assistant_hold=true;student.global_position=tower.global_position
 tower._process(0);var shot=main.map.projectiles.get_child(0);shot._process(1)
 check(tower.stats.total.get("shots",0)==1 and tower.stats.total.get("hits",0)==1 and tower.stats.total.get("knowledge",0)==20,"Actual projectile statistics")
 main.game.try_upgrade(slot);check(tower.stats.current().get("knowledge",0)==0 and tower.stats.total.get("knowledge",0)==20,"Upgrade resets current only")
 check(tower.get_upgrade_cost()==200,"Book level3 costs200")
 main.game.try_upgrade(slot);check(tower.get_sell_refund()==185,"Refund half actual370 investment")
 main.free()
 for scene in ["main_map2","main_map3","main_map4"]:
  main=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for site in main.map.slots.get_children():site.set_blocker("")
  main.game.gold=10000
  slot=main.map.slots.get_child(0);main.build(slot,"book");tower=slot.tower
  var other_slot=main.map.slots.get_child(1);main.build(other_slot,"book")
  check(tower.stats!=other_slot.tower.stats,"Statistics unique per building on every map")
  student=load("res://scenes/bookworm.tscn").instantiate();main.map.route.add_child(student)
  for hit in range(3):tower.stats.teach(student,60)
  check(tower.stats.total.get("shields",0)==3 and tower.stats.total.get("knowledge",0)==0,"Golden strength still removes one shield per hit, zero Knowledge")
  tower.stats.teach(student,60);tower.stats.teach(student,60);tower.stats.teach(student,60)
  check(tower.stats.total.get("knowledge",0)==100 and tower.stats.total.get("graduated",0)==1,"Clamped actual Knowledge and graduation once")
  student=load("res://scenes/snack_monster.tscn").instantiate();main.map.route.add_child(student)
  before=int(tower.stats.total.get("knowledge",0));tower.stats.teach(student,200);tower.stats.teach(student,300)
  check(tower.stats.total.get("knowledge",0)==before+200,"Immune Snack does not count and delivered points retained")
  student._process(2);tower.stats.teach(student,300)
  check(tower.stats.total.get("knowledge",0)==before+500 and tower.stats.total.get("graduated",0)==2,"Snack healing never subtracts delivered Knowledge")
  main.sell(slot);main.build(slot,"blackboard");tower=slot.tower
  main.game.try_upgrade(slot);check(tower.get_upgrade_cost()==220,"Science level3 price220")
  main.game.try_upgrade(slot)
  var targets=[]
  for kind in ["normal","normal","bookworm","snack"]:
   student=load("res://scenes/%s.tscn"%("student" if kind=="normal" else ("bookworm" if kind=="bookworm" else "snack_monster"))).instantiate()
   main.map.route.add_child(student);student.global_position=tower.global_position+Vector2(0,30);student.assistant_hold=true
   if kind=="snack":student.teach(200)
   targets.append(student)
  tower._process(0)
  check(tower.stats.total.get("shots",0)==1 and tower.stats.total.get("hits",0)==0,"Science counts cast, not premature impact")
  var effect=main.map.effects.get_child(main.map.effects.get_child_count()-1);effect.advance(0.7);effect.advance(0)
  check(tower.stats.total.get("hits",0)==3 and tower.stats.total.get("slows",0)==3 and tower.stats.total.get("knowledge",0)==44,"AoE3 valid hits including shield, excludes immune Snack, no double counting")
  check(tower.stats.total.get("shields",0)==1,"Science shield recorded separately")
  main.select_slot(slot);main.ui.stats_button.pressed.emit()
  check(main.ui.stats_panel.visible and main.ui.stats_rows[0][1].text=="44","Stats tab displays real lifetime counters")
  paused=true;tower.stats.add("knowledge",1);main.ui._process(0)
  check(main.ui.stats_rows[0][1].text=="45","Stats tab live refresh during pause")
  paused=false
  main.ui.stats_button.pressed.emit();check(main.ui.banner_description.visible and not main.ui.stats_panel.visible,"Info tab restores properties")
  for target in targets:target.free()
  main.sell(slot);main.build(slot,"assistant");var post=slot.tower
  var a=post.assistants[0];var b=post.assistants[1]
  for worker in [a,b]:
   student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student)
   student.global_position=post.rally_point+Vector2(10*worker.index,0)
   student.reserve_teacher(worker);worker.target=student;worker.state="approach";worker.global_position=student.global_position+Vector2(-15,0)
   worker._process(1);worker._process(1)
   student.free();worker.return_home()
  check(post.stats.total.get("stopped",0)==2 and is_equal_approx(post.stats.total.get("time",0),2) and post.stats.total.get("knowledge",0)==10,"Both assistants aggregate real stops, effective seconds and Knowledge")
  main.select_slot(slot);main.ui.stats_button.pressed.emit();check(main.ui.stats_rows[3][1].text=="2.0","Assistant time visible")
  check(main.ui.tower_banner.size.y==224 and main.ui.stats_rows[4][0].position.y+19<main.ui.tower_banner.size.y-53-25,"Stats rows stay inside compact frame")
  main.sell(slot);main.build(slot,"economy");building=slot.tower
  main.economy.complete_wave(10);main.economy.complete_wave(10)
  main.select_slot(slot);main.specialize(slot,"scholarship")
  main.waves.active=true;main.waves.remaining=1;main.economy.begin_wave(11)
  student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student);student.global_position=building.global_position
  student.resolved.connect(main.student_resolved);student.teach(100)
  check(building.stats.total.get("kp",0)==20 and building.stats.current().get("kp",0)==5,"Office retains Study income and no duplicate wave payout")
  main.ui.stats_button.pressed.emit()
  check(main.ui.stats_rows[0][1].text=="20" and main.ui.stats_rows[0][2].text=="5" and main.ui.stats_rows[3][2].text=="5 / 40","Office tab has lifetime, specialization and current wave income")
  before=main.game.gold;main.economy.begin_wave(12);main.economy.student_graduated(student)
  check(main.game.gold==before and building.wave_bonus==0,"Same completed student cannot pay again in later wave")
  main.ui._process(0);check(main.ui.stats_rows[3][2].text=="0 / 40","Wave reset updates open Stats tab")
  var independent=load("res://scripts/building_stats.gd").new();independent.add("knowledge",7)
  check(tower.stats.total.get("knowledge",0)!=7,"Independent records do not share dictionaries")
  main.free()
 print("V020: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
