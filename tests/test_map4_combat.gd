extends "res://tests/test_bookworm.gd"
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate()
 root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for site in main.map.slots.get_children(): site.set_blocker("")
 main.game.gold=10000
 var slot=main.map.slots.get_child(6)
 for route in main.map.get_routes():
  var s=load("res://scenes/snack_monster.tscn").instantiate()
  route.add_child(s);s.progress=route.curve.get_closest_offset(slot.position);s.lane_offset=12;s.update_lane_position()
  var progress_before:float=s.progress
  var lane_before:float=s.lane_offset
  main.build(slot,"book");slot.tower._process(0.1)
  var shot=main.map.projectiles.get_child(main.map.projectiles.get_child_count()-1)
  check(shot.target==s,"Book acquires each independent route")
  main.sell(slot)
  main.build(slot,"blackboard");slot.tower._process(0.1)
  check(s.teaching_points==15 and s.slow_remaining>0,"Science affects each route")
  main.sell(slot)
  main.build(slot,"assistant")
  var post=slot.tower
  check(post.try_move_rally(s.global_position),"Rally reaches either route")
  for a in post.assistants:a._process(4)
  var a=post.assistants[0];a.cooldown=0;a._process(0.01);a._process(1)
  check(s.assistant_hold and s.teacher==a,"Assistant blocks on either route")
  s.teach(200)
  check(s.is_eating() and s.teacher==null,"Eating releases assistant")
  s._process(2)
  check(s.get_parent()==route and s.progress==progress_before and s.lane_offset==lane_before,"Snack retains route, progress and lane")
  main.sell(slot)
  main.build(slot,"economy");main.select_slot(slot);main.specialize(slot,"scholarship")
  main.waves.active=true;main.waves.remaining=1;main.economy.begin_wave(1 if route==main.map.route else 2)
  var gold:int=main.game.gold
  s.resolved.connect(main.student_resolved)
  s.teach(300)
  check(s.done and main.game.gold==gold+15,"Scholarship bonus and normal reward from either route")
  main.sell(slot);s.free()
  var escaping=load("res://scenes/student.tscn").instantiate()
  route.add_child(escaping);escaping.resolved.connect(main.student_resolved)
  escaping.progress=route.curve.get_baked_length()-1
  var lives:int=main.game.lives
  escaping._process(0.1)
  check(escaping.done and main.game.lives==lives-1,"Either exit costs normal Reputation")
  escaping.free()
 main.free()
 print("MAP4 COMBAT: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
