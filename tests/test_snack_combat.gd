extends "res://tests/test_bookworm.gd"
func run()->void:
 var main=load("res://scenes/main_map3.tscn").instantiate()
 root.add_child(main)
 # Unit fixture: isolate tower/combat behavior from paid site clearing.
 for site in main.map.slots.get_children(): site.set_blocker("")
 main.process_mode=Node.PROCESS_MODE_DISABLED
 main.game.gold=1000
 var s=load("res://scenes/snack_monster.tscn").instantiate()
 main.map.route.add_child(s)
 s.progress=main.map.route.curve.get_closest_offset(Vector2(950,466))
 s.lane_offset=0;s.update_lane_position()
 var slot=main.map.slots.get_child(4)
 main.build(slot,"assistant")
 var post=slot.tower
 post.try_move_rally(s.global_position)
 for worker in post.assistants:worker._process(4)
 var worker=post.assistants[0]
 worker.cooldown=0;worker._process(0.01);worker._process(1)
 check(s.assistant_hold and s.teacher==worker,"Assistant blocks before snack")
 s.teach(200)
 check(not s.assistant_hold and s.teacher==null and worker.target==null,"Snack releases active assistant immediately")
 worker._process(4);worker.cooldown=0;worker._process(0.01)
 check(worker.target==null,"Assistant cannot reacquire eating enemy")
 main.sell(slot);main.build(slot,"book")
 slot.tower._process(0.1)
 check(main.map.projectiles.get_child_count()==0,"Book Tower ignores eating target")
 var other=load("res://scenes/student.tscn").instantiate()
 main.map.route.add_child(other)
 other.assistant_hold=true # Static neighbor fixture.
 other.global_position=s.global_position+Vector2(20,0)
 slot.tower._process(0.1)
 var projectile=main.map.projectiles.get_child(0)
 check(projectile.target==other,"Book Tower retargets another student")
 var inflight=load("res://scenes/projectile.tscn").instantiate()
 main.map.projectiles.add_child(inflight);inflight.configure(s,60,true)
 inflight._process(1)
 check(inflight.spent and s.knowledge==50,"In-flight golden book is harmless")
 main.sell(slot);main.build(slot,"blackboard")
 slot.tower._process(0.1)
 for effect in main.map.effects.get_children():
  if effect.has_method("advance"):effect.advance(0.7)
 check(other.knowledge==15 and other.slow_remaining>0,"AoE still affects neighbor")
 check(s.knowledge==50 and s.slow_remaining==0,"AoE and slow exclude eating enemy")
 var remaining:float=s.eating_remaining
 s.process_mode=Node.PROCESS_MODE_PAUSABLE
 paused=true
 await create_timer(0.03,true).timeout
 check(s.eating_remaining==remaining,"Pause preserves snack timer")
 paused=false
 s.process_mode=Node.PROCESS_MODE_INHERIT
 s._process(2)
 check(s.is_targetable() and s.knowledge==25,"Targetable after two active seconds")
 main.sell(slot);main.build(slot,"assistant")
 post=slot.tower;post.try_move_rally(s.global_position)
 other.free()
 for a in post.assistants:a._process(4)
 worker=post.assistants[0];worker.cooldown=0;worker._process(0.01)
 check(worker.target==s,"Assistant can reserve after snack")
 s.resolved.connect(main.student_resolved)
 var gold:int=main.game.gold
 s.teach(300)
 check(s.done and main.game.gold==gold+10,"Normal completion reward")
 main.free()
 print("SNACK COMBAT: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
