extends "res://tests/test_integration.gd"
func run():
 var base=load("res://scenes/student.tscn").instantiate()
 check(base.has_method("can_receive_attack"),"Students expose attack eligibility")
 base.slow_indicator.free();base.free()
 if not ResourceLoader.exists("res://scenes/paper_plane_pilot.tscn"):
  check(false,"Paper Plane Pilot scene exists");finish();return
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var pilot=load("res://scenes/paper_plane_pilot.tscn").instantiate();main.map.route.add_child(pilot)
 check(pilot.base_speed==102.0,"120 percent speed")
 check(pilot.bar.max_value==150,"150 Knowledge required")
 for kind in ["blackboard","assistant","janitor","other"]:
  check(not pilot.can_receive_attack(kind),"Reject "+kind)
 check(pilot.can_receive_attack("book"),"Accept Book Tower")
 pilot.teach(50);check(pilot.knowledge==0,"Unsourced Knowledge rejected")
 pilot.apply_slow(5,0.4,"science");check(pilot.slow_remaining==0,"Slow immunity")
 check(not pilot.reserve_teacher(main),"Assistant cannot reserve")
 pilot.receive_attack(100,"book");check(pilot.knowledge==100 and not pilot.done,"100 is not graduation")
 pilot.receive_attack(50,"book");check(pilot.done,"150 graduates")
 for w in [13,14,15]:
  main.waves.wave=w
  var route_counts=[0,0];var planes=[0,0]
  for i in range(main.waves.counts[w-1]):
   var route:int=main.waves.get_spawn_route(i);route_counts[route]+=1
   if main.waves.get_spawn_kind(i)=="pilot":planes[route]+=1
  if w==13:check(route_counts[0]==0,"Wave13 lower only")
  if w==14:check(route_counts[1]==0,"Wave14 upper only")
  if w==15:
   check(route_counts==[main.waves.counts[13],main.waves.counts[12]],"Finale exact route counts")
   check(planes[0]>0 and planes[1]>0,"Planes on both finale routes")
 check(main.waves.counts[14]==main.waves.counts[12]+main.waves.counts[13],"Finale sums prior waves")

 # Real attack paths, stats, reward and defeat lifecycle on both maps/routes.
 main.free()
 for scene in ["main","main_map2","main_map3","main_map4"]:
  var level=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(level);level.process_mode=Node.PROCESS_MODE_DISABLED
  check(level.waves.counts.size()==(7 if scene=="main" else (12 if scene=="main_map2" else (15 if scene=="main_map3" else 17))),"Wave length preserved "+scene)
  for w in range(level.waves.counts.size()):
   level.waves.wave=w+1
   var tally={"normal":0,"pe":0,"bookworm":0,"snack":0,"pilot":0}
   for i in range(level.waves.counts[w]):tally[level.waves.get_spawn_kind(i)]+=1
   check(tally.pilot==level.waves.pilot_counts[w],"Exact air count")
   check(tally.snack==level.waves.snack_counts[w] and tally.bookworm==level.waves.bookworm_counts[w] and tally.pe==level.waves.pe_counts[w],"Preserve all wave mixes")
   if level.map.level_id<3 or w<4:check(tally.pilot==0,"No early air units")
  if level.map.level_id>=3:
   for route in level.map.get_routes():
    var unit=load("res://scenes/paper_plane_pilot.tscn").instantiate();route.add_child(unit);unit.progress=400;unit.update_lane_position()
    for facing in ["side","front","back"]:
     check(unit.frames[facing].size()==9,"All supplied poses used")
     for texture in unit.frames[facing]:check(texture.get_size()==Vector2(240,270),"Stable frame canvas")
    var before_progress:float=unit.progress;unit._process(0.1)
    check(is_equal_approx(unit.progress-before_progress,10.2),"Flight movement follows its own path")
    var attack=load("res://scripts/science_attack.gd").new();attack.configure_science(1,105);attack.configure_impact(level.map,999,105,5,0.4);level.map.effects.add_child(attack);attack.global_position=unit.global_position;attack.impact()
    check(unit.knowledge==0 and unit.slow_remaining==0 and not unit.slow_indicator.visible,"Real science impact ignores pilot")
    var stats=load("res://scripts/building_stats.gd").new()
    check(not stats.teach(unit,999,"assistant"),"Stats rejects ground Knowledge")
    level.waves.wave=11;level.waves.active=true;level.waves.remaining=1
    unit.resolved.connect(level.student_resolved)
    var gold:int=level.game.gold
    for shot in range(5):
     var book=load("res://scenes/projectile.tscn").instantiate();level.map.projectiles.add_child(book);book.configure(unit,30);book.source_stats=stats;book.global_position=unit.global_position+Vector2(0,-75);book._process(0.01)
    check(unit.done and unit.defeated,"Real Book Tower projectiles graduate")
    check(stats.total.knowledge==150 and stats.total.graduated==1 and stats.total.hits==5,"Book statistics count actual Knowledge and graduation")
    check(level.game.gold==gold+6,"Pilot obeys wave reward reduction")
    check(unit.get_parent()==level.map.effects and unit.visible,"Own defeat plays after resolving route")
    unit._process(0.4);check(unit.is_queued_for_deletion(),"Defeat ends cleanly")
  level.free()
 finish()
func finish():
 print("V023: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
