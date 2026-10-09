extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok:
  failures+=1
  print("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 # Unit fixture: isolate tower/combat behavior from paid site clearing.
 for site in main.map.slots.get_children(): site.set_blocker("")
 main.process_mode=Node.PROCESS_MODE_DISABLED
 main.game.gold=1000
 var slot=main.map.slots.get_child(2)
 main.build(slot,"book")
 check(main.game.has_method("try_upgrade"),"Manager supports atomic upgrades")
 if not main.game.has_method("try_upgrade"):
  print("UPGRADES: %d checks, %d failures"%[checks,failures])
  main.free();quit(1);return
 var tower=slot.tower
 var position_before:Vector2=tower.global_position
 tower.cooldown=0.71
 check(main.game.try_upgrade(slot),"Book upgrades to2")
 check(tower.level==2 and tower.knowledge_per_hit==25 and is_equal_approx(tower.fire_interval,0.8) and tower.teaching_range==286.0,"Book2 stats")
 check(main.game.gold==830 and tower.total_invested==170,"Charge100 once")
 check(tower.cooldown==0.71 and tower.global_position==position_before and slot.tower==tower,"Preserve node, origin and cooldown")
 check(main.game.try_upgrade(slot),"Book upgrades to3")
 check(tower.level==3 and tower.knowledge_per_hit==30 and is_equal_approx(tower.fire_interval,0.65) and tower.teaching_range==312.0,"Book3 stats")
 check(main.game.gold==680 and tower.total_invested==320,"Charge150 once")
 check(not main.game.try_upgrade(slot) and main.game.gold==680,"Max rejects without charge")
 check(main.game.try_sell(slot) and main.game.gold==840,"Book3 refunds160")
 check(not main.game.try_upgrade(slot),"Reject sold slot")
 main.build(slot,"blackboard")
 tower=slot.tower
 check(main.game.try_upgrade(slot),"Board upgrades2")
 check(tower.level==2 and tower.area_radius==126.0 and tower.knowledge_per_hit==19 and tower.slow_duration==2.5 and tower.slow_strength==0.3,"Board2 stats")
 check(main.game.try_upgrade(slot),"Board upgrades3")
 check(tower.level==3 and tower.area_radius==147.0 and tower.knowledge_per_hit==22 and tower.slow_strength==0.4 and tower.slow_duration==2.5,"Board3 stats")
 check(tower.teaching_range==225 and tower.fire_interval==1.3,"Board range and attack interval preserved")
 main.game.gold=0
 check(not main.game.try_upgrade(slot),"Max no purchase")
 check(main.game.try_sell(slot) and main.game.gold==195,"Board3 refunds195")
 main.game.gold=100
 main.build(slot,"book")
 check(not main.game.try_upgrade(slot) and main.game.gold==30 and slot.tower.level==1,"Reject unaffordable without mutation")
 main.game.gold=1000
 main.select_slot(slot)
 check(main.ui.tower_panel.position.y>=940 and main.ui.tower_panel.size.y<=180,"Compact fixed bottom banner")
 check(main.ui.upgrade_button.visible and not main.ui.upgrade_button.disabled,"Upgrade available in banner")
 check(main.upgrade(slot),"Selected tower upgrade action")
 check(main.ui.tower_title.text.contains("Advanced Book") and main.ui.sell_button.text.contains("85"),"Live banner and invested refund")
 main.game.gold=0;main.game.changed.emit()
 check(main.ui.upgrade_button.disabled and main.ui.upgrade_button.tooltip_text.contains("150"),"Cost visible while disabled")
 main.clear_selection()
 check(not main.ui.tower_panel.visible and not slot.tower.show_range,"Deselect clears banner/range")
 check(not main.upgrade(slot),"Stale selection cannot buy")
 main.game.gold=1000
 # Actual firing counter is per tower and starts when Scholar is reached.
 tower=slot.tower
 main.game.try_upgrade(slot)
 var student=load("res://scenes/student.tscn").instantiate()
 main.map.route.add_child(student)
 student.progress=800
 tower.global_position=student.global_position+Vector2(100,0)
 for i in range(10):
  tower.cooldown=0
  tower._process(0)
  var projectile=main.map.projectiles.get_child(main.map.projectiles.get_child_count()-1)
  check(projectile.golden==((i+1)%5==0),"Every fifth actual Scholar shot golden")
  check(projectile.knowledge==(60 if (i+1)%5==0 else 30),"Golden doubles Knowledge only")
  check(projectile.letter in ["A","B","C"] and projectile.flight_frames.size()==1,"Golden retains single-frame book")
  projectile.free()
 student.free()
 for kind in ["normal","pe"]:
  for sex in ["boy","girl"]:
   var s=load("res://scenes/student.tscn").instantiate()
   s.configure(kind,sex)
   main.map.route.add_child(s)
   s.progress=800
   s.apply_slow(2.5,0.4)
   check(is_equal_approx(s.speed,s.base_speed*0.6) and s.slow_indicator.visible,"40 percent slow and drip for every type")
   s.apply_slow(2.0,0.3)
   check(s.slow_strength==0.4 and s.slow_remaining==2.5,"Slow never stacks or weakens")
   var before:float=s.progress
   s._process(3.0)
   check(is_equal_approx(s.progress-before,s.base_speed*2.0),"Slow expiry splits movement correctly")
   check(s.speed==s.base_speed and not s.slow_indicator.visible and s.slow_strength==0,"Normal speed/drip reset at expiry")
   s.apply_slow(2.5,0.4)
   s._process(1.0)
   s.apply_slow(2.5,0.4)
   check(s.slow_remaining==2.5 and s.slow_strength==0.4,"Hits refresh duration without stacking")
   s.free()
 main.game.try_sell(slot)
 main.game.gold=1000
 main.build(slot,"blackboard")
 tower=slot.tower
 for level in range(1,4):
  if level>1: main.game.try_upgrade(slot)
  var students=[]
  for type in ["normal","pe_boy","pe_girl"]:
   var s=load("res://scenes/student.tscn").instantiate()
   s.configure("normal" if type=="normal" else "pe","girl" if type=="pe_girl" else "boy")
   main.map.route.add_child(s)
   s.progress=800
   students.append(s)
  tower.global_position=students[0].global_position+Vector2(0,-10)
  tower.cooldown=0
  tower._process(0)
  for s in students:
   check(s.knowledge==[15,19,22][level-1],"Actual Board hit Knowledge all types, level%d" % level)
   check(s.slow_remaining==tower.slow_duration and s.slow_strength==tower.slow_strength,"Actual Board slow/drips all types")
   check(s.slow_indicator.visible,"Actual AoE hit has drip")
   s.free()
 main.game.try_sell(slot)
 main.game.gold=1000
 main.build(slot,"book")
 paused=true
 check(not main.game.try_upgrade(slot) and slot.tower.level==1 and main.game.gold==930,"Paused cannot buy")
 paused=false
 main.game.finished=true
 check(not main.game.try_upgrade(slot) and slot.tower.level==1,"Finished cannot buy")
 main.game.finished=false
 var original_game=slot.tower.game
 slot.tower.game=null
 check(not main.game.try_upgrade(slot),"Foreign ownership rejected")
 slot.tower.game=original_game
 main.game.try_sell(slot)
 main.build(slot,"assistant")
 check(not main.game.try_upgrade(slot) and slot.tower.tower_type=="assistant","Assistant not upgraded")
 main.free()
 print("UPGRADES: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
