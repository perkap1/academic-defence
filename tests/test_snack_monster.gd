extends "res://tests/test_bookworm.gd"
func run()->void:
 check(FileAccess.file_exists("res://scenes/snack_monster.tscn"),"Snack Monster exists")
 var world=load("res://scenes/world_map.tscn").instantiate()
 root.add_child(world)
 check(world.can_open_level(2),"Map3 available on fresh save")
 check(not world.can_open_level(3) and not world.can_open_level(4),"Future maps remain locked")
 world.free()
 if not FileAccess.file_exists("res://scenes/snack_monster.tscn"):
  print("SNACK: %d checks, %d failures"%[checks,failures]);quit(1);return
 var main=load("res://scenes/main_map3.tscn").instantiate()
 root.add_child(main)
 main.process_mode=Node.PROCESS_MODE_DISABLED
 for route in main.map.get_routes():
  var s=load("res://scenes/snack_monster.tscn").instantiate()
  route.add_child(s)
  s.progress=400;s.update_lane_position()
  for facing in ["front","side","back"]:
   check(s.frames[facing].size()==10,"Two idle, four walk, four eat poses")
   for frame in s.frames[facing]:check(frame.get_size()==Vector2(180,240),"Fixed sprite canvas")
  check(is_equal_approx(s.base_speed,59.5),"70 percent walking speed")
  s.teach(199)
  check(not s.snack_break_used and s.knowledge<50,"Fourfold resistance before threshold")
  s.teach(1000)
  check(s.snack_break_used and s.is_eating() and not s.done,"Overshoot starts eating before graduation")
  var position_before:Vector2=s.global_position
  var progress_before:float=s.progress
  var knowledge_before:float=s.knowledge
  s.teach(9999);s.apply_slow(9,0.9);s.show_wet_hit()
  check(s.knowledge==knowledge_before and s.slow_remaining==0,"Central immunity blocks knowledge and slow")
  check(not s.reserve_teacher(main),"Cannot reserve eating student")
  check(not s.is_targetable(),"Eating cannot be targeted")
  s.complete(true)
  check(not s.done,"Cannot graduate while eating")
  s._process(1.999)
  check(s.is_eating() and s.global_position==position_before and s.progress==progress_before,"No movement during first 1.999 seconds")
  s._process(0.001)
  check(not s.is_eating() and s.knowledge==25,"Exactly 2 seconds sets knowledge to 25 percent")
  check(s.global_position==position_before,"Healing does not move student")
  s._process(0.1)
  check(s.progress>progress_before,"Resumes walking")
  s.teach(100)
  check(not s.is_eating() and s.snack_break_used and s.knowledge==50,"Second threshold never heals again")
  s.teach(200)
  check(s.done,"Graduates normally after snack consumed")
 for id in [2,3]:
  var level=load("res://scenes/main_map%d.tscn"%id).instantiate()
  root.add_child(level);level.process_mode=Node.PROCESS_MODE_DISABLED
  var waves=level.waves
  check(waves.counts.size()==(12 if id==2 else 15),"Wave total unchanged")
  for w in range(waves.counts.size()):
   waves.wave=w+1
   var tally={"normal":0,"pe":0,"bookworm":0,"snack":0}
   for i in range(waves.counts[w]): tally[waves.get_spawn_kind(i)]+=1
   check(tally.snack==waves.snack_counts[w],"Exact snack count wave %d map %d"%[w+1,id])
   check(tally.pe==waves.pe_counts[w] and tally.bookworm==waves.bookworm_counts[w],"Other types preserved")
  level.free()
 main.free()
 print("SNACK: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
