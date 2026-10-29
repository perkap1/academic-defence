extends SceneTree
var checks:=0
var failures:=0
func check(ok:bool,message:String)->void:
 checks+=1
 if not ok:
  failures+=1
  print("FAIL: "+message)
func _initialize()->void: call_deferred("run")
func run()->void:
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 # Unit fixture: isolate tower/combat behavior from paid site clearing.
 for site in main.map.slots.get_children(): site.set_blocker("")
 main.process_mode=Node.PROCESS_MODE_DISABLED
 main.game.gold=2000
 var slot=main.map.slots.get_child(2)
 main.build(slot,"book")
 var tower=slot.tower
 check(tower.has_method("get_visual_frame"),"New tower animation timeline exists")
 if not tower.has_method("get_visual_frame"):
  main.free();print("PRESENTATION: %d checks, %d failures"%[checks,failures]);quit(1);return
 for level in range(1,4):
  if level>1: main.game.try_upgrade(slot)
  var expected=[0,0,0,1,1,1,2,2,3,3]
  tower.animation_time=0
  for i in range(expected.size()):
   tower.visual_time=i*0.25
   check(tower.get_visual_frame()==expected[i],"Comic reading and coffee idle level%d"%level)
  tower.animation_time=0.2
  check(tower.get_visual_frame()==7,"Comic throw sequence all Book levels")
  check(tower.frames.size()==9 and tower.frames[0] is AtlasTexture,"User sheet used directly")
 main.game.try_sell(slot)
 main.build(slot,"blackboard")
 tower=slot.tower
 for level in range(1,4):
  if level>1: main.game.try_upgrade(slot)
  tower.animation_time=0
  for time in [0.0,0.4,1.2,5.0]:
   tower.visual_time=time
   check(tower.get_visual_frame()==int(floor(time*1.5+0.00001))%6,"Science calm idle matches Book Tower speed")
  for i in range(5):
   tower.animation_time=0.4-i*0.08
   check(tower.get_visual_frame()==i+6,"Ordered5 science attack frames")
  var effect=tower.create_attack_effect()
  main.map.effects.add_child(effect)
  check(effect.frames.size()==5 and effect.frames[0] is AtlasTexture,"Five science cloud frames")
  check(effect.effect_level==level,"Science effect retains gameplay level")
  for i in range(5):
   effect.elapsed=0
   effect.advance((i+0.02)*0.09)
   check(effect.sprite.texture==effect.frames[i],"Five science cloud frames shown in order")
  effect.free()
 check(main.ui.upgrade_button.state_frames.size()==4,"Supplied4 arrow states")
 var student=load("res://scenes/student.tscn").instantiate()
 main.map.route.add_child(student)
 check(student.scale==Vector2(0.7,0.7),"Student70percent scale")
 check(student.get("lane_offset")!=null,"Student has lateral lane")
 student.free()
 var pe=load("res://scenes/pe_teacher.tscn").instantiate();root.add_child(pe)
 var post=load("res://scenes/assistant_post.tscn").instantiate();root.add_child(post)
 for time in [0.0,0.5,0.7,1.4,2.1,3.0]:
  var expected_idle:=int(time*1.5)%4
  pe.visual_time=time;pe.animation_time=0;pe.update_sprite(0)
  check(pe.sprite.texture==pe.frames[expected_idle],"PE idle matches Book and Science cadence")
  post.animation_time=time;post.point_remaining=0;post._process(0)
  check(post.sprite.texture==post.idle_frames[expected_idle],"Assistant Post idle matches shared cadence")
 post.point_at(post.global_position+Vector2.RIGHT*100);post._process(0.18)
 check(post.sprite.texture==post.point_frames[1],"Pointing retains six frames per second")
 for branch in ["study","library","scholarship"]:
  var economy=load("res://scenes/economy_building.tscn").instantiate();root.add_child(economy)
  if branch!="study":economy.specialize(branch)
  for time in [0.0,0.5,0.7,1.4,2.1,3.0,5.0]:
   economy.visual_time=time;economy.active_time=0;economy._process(0)
   check(economy.sprite.texture==economy.frames[int(time*1.5)%8],"Economy idle matches shared cadence: "+branch)
  economy.free()
 pe.free();post.free()
 main.free()
 print("PRESENTATION: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
