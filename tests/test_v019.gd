extends "res://tests/test_integration.gd"
func spawn(main,path,kind:String="normal",sex:String="boy"):
 var s=load("res://scenes/snack_monster.tscn" if kind=="snack" else ("res://scenes/bookworm.tscn" if kind=="bookworm" else "res://scenes/student.tscn")).instantiate()
 s.configure(kind,sex);path.add_child(s);s.progress=500;s.lane_offset=12;s.update_lane_position()
 return s
func run():
 var game=load("res://scripts/game_manager.gd").new()
 game.lives=20;root.add_child(game);game.won=true
 for data in [[20,3],[16,2],[14,2],[13,1],[8,1]]:
  game.lives=data[0];check(game.get_star_rating()==data[1],"Rating threshold against actual20 starting Reputation")
 game.won=false;check(game.get_star_rating()==0,"Defeat earns no rating")
 game.free()
 var progress=load("res://scripts/progression.gd").new();root.add_child(progress)
 progress.save_path="user://v019_regression_only.cfg";progress.persist_enabled=true
 var old=ConfigFile.new();old.set_value("progress","completed_levels",[1,3]);old.set_value("progress","bookworm_seen",true);old.save(progress.save_path)
 progress.load_progress()
 check(progress.get_stars(1)==1 and progress.get_stars(3)==1 and progress.bookworm_seen,"Old save migrates without losing progress")
 progress.complete_level(1,3);progress.complete_level(1,2)
 check(progress.get_stars(1)==3,"Inferior replay cannot overwrite best")
 progress.complete_level(2,0);check(2 not in progress.completed_levels,"Defeat cannot unlock")
 progress.complete_level(4,2);progress.best_stars.clear();progress.load_progress()
 check(progress.get_stars(1)==3 and progress.get_stars(4)==2,"Best stars survive save/load")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(progress.save_path));progress.free()
 var world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 for id in range(1,5):
  check(world.find_child("Level%dStars"%id,true,false)!=null,"World Map has star row for each existing map")
 check(world.can_open_level(2) and not world.can_open_level(4),"Map3 open, Map5 locked independently of ratings")
 world.free()
 for scene in ["main_map3","main_map4"]:
  var main=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for site in main.map.slots.get_children():site.set_blocker("")
  main.game.gold=10000
  var slot=main.map.slots.get_child(4 if scene=="main_map3" else 6)
  main.build(slot,"blackboard");var tower=slot.tower
  for level in range(1,4):
   if level>1:main.game.try_upgrade(slot)
   for path in main.map.get_routes():
    var s=spawn(main,path)
    tower.global_position=s.global_position+Vector2(-40,0);tower.cooldown=0
    var expected:Vector2=s.predict_position(0.7)
    tower._process(0)
    var effect=main.map.effects.get_child(main.map.effects.get_child_count()-1)
    check(effect.global_position.distance_to(expected)<0.01,"Fixed curve/lane landing prediction")
    check(s.knowledge==0 and s.slow_remaining==0,"No Knowledge/slow at launch")
    effect.advance(0.35)
    check(effect.orb.position.y<effect.ground_position.y-100,"Visible apex even at short range")
    check(not effect.sprite.visible and s.knowledge==0,"Cloud and teaching wait for ground")
    s._process(0.7)
    effect.advance(0.35)
    check(effect.impacted and effect.sprite.visible and not effect.orb.visible,"Landing transitions to existing cloud")
    check(s.knowledge==tower.knowledge_per_hit and s.has_science_slow(),"Each level impacts either route with original stats")
    check(s.bar_fill.bg_color==Color("bd65ef"),"Landing makes fill purple")
    var value:int=s.knowledge;effect.advance(0)
    check(s.knowledge==value,"AoE impact happens once")
    effect.advance(0.46);check(effect.is_queued_for_deletion(),"Flight and cloud retire")
    effect.free();s.free()
  for kind in [["normal","boy"],["pe","boy"],["pe","girl"],["bookworm","boy"],["snack","boy"]]:
   var s=spawn(main,main.map.route,kind[0],kind[1])
   s.teach(10)
   var value:float=s.bar.value;var bar_pos:Vector2=s.bar.position;var bar_size:Vector2=s.bar.size
   var normal:Color=s.bar_fill.bg_color
   s.apply_slow(0.3,0.3,"other")
   check(s.bar_fill.bg_color==normal,"Non-science slow keeps normal fill")
   s.apply_slow(0.2,0.3,"science")
   check(s.bar_fill.bg_color==Color("bd65ef") and s.bar.value==value and s.bar.position==bar_pos and s.bar.size==bar_size,"Purple changes only fill for each enemy")
   s._process(0.1);s.apply_slow(0.2,0.3,"science");s._process(0.15)
   check(s.has_science_slow(),"Refresh keeps source active")
   s._process(0.06);check(not s.has_science_slow() and s.bar_fill.bg_color==normal,"Actual expiry restores fill")
   if kind[0]=="bookworm":check(s.books==2 and s.knowledge==0,"Book shield unchanged")
   if kind[0]=="snack":
    s.apply_slow(2,0.4,"science");s.teach(200)
    check(s.is_eating() and not s.has_science_slow() and s.bar_fill.bg_color==normal,"Snack Break clears source and color immediately")
    s.apply_slow(2,0.4,"science");check(s.slow_remaining==0,"Snack rejects new slow")
   s.free()
  var target=spawn(main,main.map.route);target.apply_slow(0.2,0.3,"science")
  var before:float=target.progress;var expected:Vector2=target.predict_position(0.7);target._process(0.7)
  check(target.global_position.distance_to(expected)<0.01 and target.progress>before,"Prediction integrates slow expiry and curves")
  tower.global_position=target.global_position;tower.cooldown=0;tower._process(0)
  var shot=main.map.effects.get_child(main.map.effects.get_child_count()-1);var landing:Vector2=shot.global_position
  target.free();shot.advance(0.7)
  check(shot.impacted and shot.global_position==landing,"Target deletion does not cancel or redirect flight")
  shot.free()
  main.game.won=true;main.game.lives=main.game.starting_reputation
  main.ui.show_result(true,main.game,17,17)
  check(main.ui.result_stars.earned==3 and main.ui.result_body.text.contains("3 / 3"),"Victory displays current rating and Reputation")
  main.free()
 # Real engine pause and speed: status and flight share the same scaled clock.
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main)
 main.waves.set_process(false)
 var s=spawn(main,main.map.route);s.apply_slow(4,0.3,"other");s.apply_slow(0.3,0.3,"science")
 var shot=load("res://scripts/science_attack.gd").new();shot.configure_science(1,105);shot.configure_impact(main.map,15,105,2,0.3)
 main.map.effects.add_child(shot);shot.global_position=s.predict_position(0.7);shot.launch_from(s.global_position+Vector2(-250,-65))
 paused=true;var remaining:float=s.slow_remaining
 await create_timer(0.08,true,false,true).timeout
 check(shot.elapsed==0 and s.slow_remaining==remaining and s.has_science_slow(),"Pause freezes flight and actual slow/color")
 paused=false;Engine.time_scale=2
 await create_timer(0.19,true,false,true).timeout
 check(shot.elapsed>0.3 and not shot.impacted and not s.has_science_slow() and s.slow_remaining>0,"Double speed advances source expiry without clearing other slow")
 check(s.bar_fill.bg_color==s.normal_bar_color,"Other slow outlives purple Science source")
 await create_timer(0.22,true,false,true).timeout
 check(shot.impacted,"Double speed lands after scaled flight time")
 Engine.time_scale=1
 # Missed original target: only the units actually at the fixed landing are hit.
 shot.free();s.free()
 var original=spawn(main,main.map.route);original.assistant_hold=true
 var neighbor=spawn(main,main.map.route);neighbor.assistant_hold=true
 var landing:Vector2=original.global_position
 shot=load("res://scripts/science_attack.gd").new();shot.configure_science(1,105);shot.configure_impact(main.map,15,105,2,0.3)
 main.map.effects.add_child(shot);shot.global_position=landing;shot.launch_from(landing+Vector2(-260,-65))
 original.global_position+=Vector2(300,0);shot.advance(0.7)
 check(original.knowledge==0 and neighbor.knowledge==15 and shot.global_position==landing,"Fixed landing hits actual neighbor and misses diverted target")
 main.game.finished=true;main.on_ended(false)
 check(shot.is_queued_for_deletion(),"Result removes airborne and impact effects instead of freezing them")
 main.free()
 var display=load("res://scripts/stars_display.gd").new();root.add_child(display)
 display.configure(2,true)
 await create_timer(1.1).timeout
 check(display.stars[0].texture==display.GOLD and display.stars[1].texture==display.GOLD and display.stars[2].texture==display.GREY,"Sequential pop settles on correct earned and grey stars")
 check(display.stars[0].scale==Vector2.ONE and display.stars[1].scale==Vector2.ONE,"Star pop returns to stable size")
 display.free()
 print("V019: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
