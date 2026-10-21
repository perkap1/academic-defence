extends "res://tests/test_integration.gd"

func pupil(main, kind:String, path:Path2D, at:float, sex:String="boy"):
 var file={"normal":"student","pe":"student","bookworm":"bookworm","snack":"snack_monster","clown":"class_clown","pilot":"paper_plane_pilot"}[kind]
 var unit=load("res://scenes/%s.tscn"%file).instantiate()
 unit.configure(kind,sex)
 path.add_child(unit);unit.progress=at;unit.lane_offset=0;unit.update_lane_position()
 return unit

func run():
 check(FileAccess.file_exists("res://scenes/pe_teacher.tscn"),"PE Teacher scene exists")
 check(FileAccess.file_exists("res://scripts/medicine_ball.gd"),"Path-following medicine ball exists")
 if failures:
  print("PE TEACHER: %d checks, %d failures"%[checks,failures]);quit(1);return
 var access=load("res://scripts/pe_road_access.gd")
 for id in range(1,6):
  var main=load("res://scenes/%s.tscn"%("main" if id==1 else "main_map%d"%id)).instantiate()
  root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED;main.game.gold=10000
  var valid_count=0;var invalid_count=0
  for slot in main.map.slots.get_children():
   slot.set_blocker("")
   var allowed=access.can_build(main.map,slot)
   main.ui.open_build_menu(slot,main.game)
   check(main.ui.pe_button.disabled==not allowed,"Menu matches road access map%d"%id)
   if allowed:valid_count+=1
   else:
    invalid_count+=1
    var before=main.game.gold
    main.build(slot,"pe_teacher")
    check(not slot.occupied and main.game.gold==before,"Invalid sites reject direct build without payment")
  check(valid_count>0,"Roadside sites available on map%d"%id)
  check(invalid_count>0,"Distant or obstructed sites rejected on map%d"%id)
  var slot=null
  for site in main.map.slots.get_children():
   if access.can_build(main.map,site):slot=site;break
  var original=slot.global_position
  slot.set_blocker("school_books");main.build(slot,"pe_teacher")
  check(not slot.occupied,"Blocked roadside site still requires clearing")
  slot.set_blocker("");main.build(slot,"pe_teacher")
  var tower=slot.tower
  check(is_instance_valid(tower) and tower.tower_type=="pe_teacher","Build PE Teacher on each map")
  check(tower.total_invested==150 and tower.knowledge_per_hit==50,"Initial price and current L1 Knowledge")
  main.select_slot(slot)
  for expected in [2,3]:
   var price=tower.get_upgrade_cost();var before=main.game.gold
   main.ui.request_upgrade()
   check(main.ui.upgrade_confirmation.visible and main.ui.upgrade_confirmation.dialog_text.contains("%d KP"%price),"Upgrade confirmation shows current price")
   check(main.game.gold==before and tower.level==expected-1,"Opening confirmation never spends KP")
   main.ui.upgrade_confirmation.confirmed.emit();main.ui.upgrade_confirmation.hide()
   check(tower.level==expected,"Confirmation upgrades through existing controller")
   check(main.game.gold==before-price and tower.level==expected,"Upgrade price charged exactly once")
   check(tower.global_position==original,"Upgrade preserves tower position")
   check(tower.knowledge_per_hit==[50,70,90][expected-1],"Knowledge follows current balance")
   check(tower.roll_distance==[240,350,480][expected-1],"Doubled roll distance grows")
   check(is_equal_approx(tower.ball_size,[1.0,1.15,1.35][expected-1]),"Ball size grows")
  check(not main.game.try_upgrade(slot),"Level3 cannot upgrade")
  check(main.ui.banner_extra.text.contains("480") and main.ui.banner_extra.text.contains("135"),"UI shows roll distance and size")
  var before=main.game.gold
  check(main.sell(slot) and main.game.gold==before+315,"50 percent of total630 investment refunded")
  main.free()
 var main=load("res://scenes/main_map2.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 var path=main.map.get_routes()[0];var at=500.0
 var units=[]
 for kind in ["normal","pe","bookworm","snack","clown","pilot"]:units.append(pupil(main,kind,path,at+25))
 units[3].teach(200);check(units[3].is_eating(),"Snack fixture eating")
 var shot=tower.launch_ball(path,at)
 var start=path.to_global(path.curve.sample_baked(at))
 shot.advance(shot.FLIGHT_TIME)
 check(shot.global_position.distance_to(start)<0.1 and shot.state=="rolling","Ball lands exactly on selected road")
 shot.advance(0.15)
 check(units[0].knowledge==50 and units[1].knowledge==50,"Swept rolling hits normal and PE")
 check(units[2].books==2 and units[2].knowledge==0,"One shield per medicine ball")
 check(units[3].teaching_points==200 and units[4].knowledge==50,"Eating immunity and Class Clown hit")
 check(units[5].knowledge==0,"Pilot immune to ground ball")
 shot.advance(0.01)
 check(units[2].books==2,"Repeated overlap never removes another book")
 check(tower.stats.total.get("shots",0)==1 and tower.stats.total.get("hits",0)==4,"Shots and valid hits recorded")
 check(tower.stats.total.get("max_hits",0)==4,"One-ball hit record")
 check(tower.stats.total.get("knowledge",0)==150,"Actual knowledge excludes shield and immune targets")
 var graduating=pupil(main,"normal",path,at+100);graduating.knowledge=50
 graduating.resolved.connect(main.student_resolved)
 main.waves.wave=1
 var reward_before:int=main.game.gold
 tower.upgrade_level()
 shot.advance(1)
 check(shot.state=="burst" and shot.distance_travelled==240,"Ball bursts after doubled maximum travel")
 check(units[0].knowledge==50,"Burst does no extra damage")
 check(tower.stats.current().get("hits",0)==0,"Old ball stats remain in firing level")
 check(tower.stats.stages[0].get("hits",0)==5 and tower.stats.total.get("max_hits",0)==5,"Old ball updates original level and total record after upgrade")
 check(tower.stats.total.get("knowledge",0)==200 and tower.stats.total.get("graduated",0)==1,"Final hit records only remaining Knowledge and one graduation")
 check(main.game.gold==reward_before+10,"PE graduation uses existing KP payout exactly once")
 shot.advance(1);check(shot.is_queued_for_deletion(),"Burst cleans up projectile")
 # Both entrances share the identical outgoing road; rolling can hit either stream there.
 var other_path=main.map.get_routes()[1]
 var common=Vector2(1213,579)
 var common_at=path.curve.get_closest_offset(common)
 var second=pupil(main,"normal",other_path,other_path.curve.get_closest_offset(common))
 var shared=tower.launch_ball(path,common_at-40);shared.advance(shared.FLIGHT_TIME);shared.advance(0.3)
 check(second.knowledge==70,"Merged streams share medicine ball collisions")
 for unit in units:unit.free()
 graduating.free()
 second.free();main.free()
 # Exercise the real windup/launch pipeline and forward curve travel on every
 # entrance of all five maps, including curving and independent routes.
 for id in range(1,6):
  main=load("res://scenes/%s.tscn"%("main" if id==1 else "main_map%d"%id)).instantiate()
  root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
  for route in main.map.get_routes():
   var offset:float=route.curve.get_baked_length()*0.4
   var target=pupil(main,"normal",route,offset)
   tower.global_position=target.global_position+Vector2(-40,40);tower.cooldown=0
   var old_count=main.map.projectiles.get_child_count()
   tower._process(0)
   check(main.map.projectiles.get_child_count()==old_count,"Throw has a real preparation phase")
   tower._process(0.6)
   check(main.map.projectiles.get_child_count()==old_count+1,"Exactly one ball released at throw pose")
   var ball=main.map.projectiles.get_child(old_count)
   check(ball.path==route and ball.progress>=offset,"Flight remembers selected entrance and forward prediction")
   ball.advance(ball.FLIGHT_TIME)
   check(ball.state=="rolling","Flight transitions to rolling on every entrance")
   var previous_rotation:float=ball.ball.rotation
   ball.advance(0.12)
   check(ball.global_position.distance_to(route.to_global(route.curve.sample_baked(ball.progress)))<0.01,"Rolling stays on curved road centre")
   check(ball.ball.rotation!=previous_rotation,"One-frame ball spins in engine")
   check(ball.dust.visible and not ball.trail.visible,"Flight trail switches to ground dust")
   ball.advance(1)
   check(ball.state=="burst" and ball.distance_travelled==240,"Doubled roll distance is preserved at bends")
   ball.free();target.free()
   var end_at:float=route.curve.get_baked_length()-25
   tower.global_position=route.to_global(route.curve.sample_baked(end_at))-route.global_transform.basis_xform(load("res://scripts/unit_layout.gd").tangent(route.curve,end_at))*100
   var tail=tower.launch_ball(route,end_at)
   tail.advance(tail.FLIGHT_TIME);tail.advance(0.5)
   check(tail.state=="burst" and tail.distance_travelled<=25.01,"End of road bursts safely without looping")
   tail.free()
  # Airborne students cannot initiate the throw either.
  var pilot=pupil(main,"pilot",main.map.route,300)
  tower.global_position=pilot.global_position;tower.cooldown=0;tower.pending_path=null;tower.release_remaining=0
  var shots_before=main.map.projectiles.get_child_count();tower._process(0)
  check(main.map.projectiles.get_child_count()==shots_before and tower.release_remaining==0,"Pilot cannot be selected for windup")
  pilot.free();main.free()
 main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 for y in [480,440,300]:
  var target=pupil(main,"normal",main.map.lower_route,main.map.lower_route.curve.get_closest_offset(Vector2(920,y)))
  var ball=tower.launch_ball(main.map.lower_route,target.progress)
  ball.advance(ball.FLIGHT_TIME)
  check(target.knowledge==50,"Rolling medicine ball also hits fully hidden tunnel pupils")
  ball.free();target.free()
 main.free()
 # Two independent roads remain independent even if their world-space hit
 # radii overlap: a ball cannot teach across to a parallel path.
 main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 var independent:Path2D=main.map.lower_route
 var parallel=main.map.route.curve.duplicate();independent.curve=parallel
 independent.position=Vector2(0,20)
 var neighbour=pupil(main,"normal",independent,300)
 var ground_ball=tower.launch_ball(main.map.route,300);ground_ball.advance(ground_ball.FLIGHT_TIME);ground_ball.advance(0.15)
 check(neighbour.knowledge==0,"Overlapping radius cannot hit a separate parallel road")
 ground_ball.free();neighbour.free();main.free()
 print("PE TEACHER: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
