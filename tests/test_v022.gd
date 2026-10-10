extends "res://tests/test_integration.gd"
func run():
 var manager=load("res://scripts/game_manager.gd").new();root.add_child(manager)
 if not manager.has_method("get_student_reward_percent"):
  check(false,"Wave-based student reward model exists");manager.free();finish();return
 var percentages=[100,100,100,90,90,90,80,80,70,70,60,60,50,50,40,40,30,30,20,20]
 for i in range(percentages.size()):
  check(manager.get_student_reward_percent(i+1)==percentages[i],"Exact reward on wave%d"%(i+1))
  var before:int=manager.gold
  var paid:int=manager.resolve_student(true,10,i+1)
  check(paid==percentages[i]/10 and manager.gold-before==paid,"Actual payout matches percentage on wave%d"%(i+1))
 check(manager.get_student_reward_percent(1000)==20,"Minimum20 percent at distant wave")
 var before:int=manager.gold
 for i in range(10):manager.resolve_student(true,1,4)
 check(manager.gold-before==9,"Fractional rewards accumulate without loss")
 before=manager.gold;manager.resolve_student(true,25,19)
 check(manager.gold-before==5,"Different base rewards retain their relative value")
 manager.free()
 for scene in ["main","main_map2","main_map3","main_map4"]:
  var main=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for site in main.map.slots.get_children():site.set_blocker("")
  main.game.gold=10000;main.waves.wave=11;main.waves.active=true;main.waves.remaining=1
  for kind in ["normal","pe","bookworm","snack"]:
   var student=load("res://scenes/%s.tscn"%("bookworm" if kind=="bookworm" else ("snack_monster" if kind=="snack" else "student"))).instantiate()
   student.configure(kind);main.map.route.add_child(student)
   before=main.game.gold;student.resolved.connect(main.student_resolved)
   if kind=="bookworm":
    for hit in range(3):student.teach(100)
   if kind=="snack":
    student.teach(200);student._process(2.0);student.teach(300)
   else:student.teach(100)
   check(main.game.gold==before+6,"Every enemy earns6 at wave11 on "+scene)
   var effect=main.map.effects.get_child(main.map.effects.get_child_count()-1)
   check(effect.get_node("Reward").text=="+6 KP","Popup shows actual paid amount")
  main.update_ui();check(main.ui.activity_label.text.contains("60%"),"HUD shows current percentage")
  var slot=main.map.slots.get_child(0);main.build(slot,"economy");main.select_slot(slot);main.economy.complete_wave(1)
  check(slot.tower.stats.total.kp==15,"Study remains15 at late wave")
  main.specialize(slot,"library");main.game.try_upgrade(slot);main.economy.complete_wave(2)
  check(slot.tower.stats.current().kp==35,"Improved Library remains35")
  main.sell(slot);main.build(slot,"economy");main.select_slot(slot);main.specialize(slot,"scholarship");main.game.try_upgrade(slot)
  before=main.game.gold
  for i in range(12):
   var student=Node2D.new();main.map.add_child(student);student.global_position=slot.tower.global_position;main.economy.student_graduated(student)
  check(main.game.gold==before+50 and slot.tower.wave_bonus==50,"Expanded Office remains5 per graduate, cap50")
  main.waves.wave=3;main.waves.active=false;main.update_ui()
  check(main.ui.activity_label.text.contains("NEXT STUDENT REWARDS: 90%"),"Intermission shows next wave reward clearly")
  main.free()
 finish()
func finish():
 print("V022: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
