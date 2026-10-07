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
  var expected=[0,0,1,2,3,3,4,5,6,6]
  tower.animation_time=0
  for i in range(expected.size()):
   tower.visual_time=i*0.25
   check(tower.get_visual_frame()==expected[i],"Comic reading and coffee idle level%d"%level)
  tower.animation_time=0.2
  check(tower.get_visual_frame()==10,"Comic throw sequence all Book levels")
  check(tower.frames.size()==12 and tower.frames[0] is AtlasTexture,"User sheet used directly")
 main.game.try_sell(slot)
 main.build(slot,"blackboard")
 tower=slot.tower
 for level in range(1,4):
  if level>1: main.game.try_upgrade(slot)
  tower.animation_time=0
  for time in [0.0,0.4,1.2,5.0]:
   tower.visual_time=time
   check(tower.get_visual_frame()==int(floor(time*3.0+0.00001))%5,"Science calm idle")
  for i in range(4):
   tower.animation_time=0.4-i*0.1
   check(tower.get_visual_frame()==i+5,"Ordered4 science attack frames")
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
 main.free()
 print("PRESENTATION: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
