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
 for map_name in ["main","main_map2"]:
  var main=load("res://scenes/%s.tscn"%map_name).instantiate()
  root.add_child(main)
  # Unit fixture: isolate tower/combat behavior from paid site clearing.
  for site in main.map.slots.get_children(): site.set_blocker("")
  main.process_mode=Node.PROCESS_MODE_DISABLED
  var offsets=[]
  for i in range(30):
   var s=load("res://scenes/student.tscn").instantiate()
   s.configure("normal" if i%3==0 else "pe","girl" if i%3==2 else "boy")
   main.map.route.add_child(s)
   check(s.scale==Vector2(0.7,0.7),"All students70percent")
   if s.get("lane_offset")==null:
    check(false,"Shared lane system exists")
    s.free();main.free();print("UNIT LAYOUT: %d checks, %d failures"%[checks,failures]);quit(1);return
   offsets.append(s.lane_offset)
   check(absf(s.lane_offset)<=24,"Random lane stays bounded")
   s.lane_offset=24 if i%2==0 else -24
   var last:=Vector2.ZERO
   var length:float=main.map.route.curve.get_baked_length()
   if i<2:
    for j in range(0,int(length),12):
     s.progress=j
     s.update_lane_position()
     var center:Vector2=main.map.route.curve.sample_baked(s.progress)
     check(s.position.distance_to(center)<=24.01,"Bounded normal-side offset")
     if center.x<=70 or center.x>=1570:
      check(s.position.distance_to(center)<0.01,"Bridges force centre lane")
     if j>0:
      var near_before:Vector2=load("res://scripts/unit_layout.gd").lane_position(main.map.route.curve,j-0.05,s.lane_offset)
      var near_after:Vector2=load("res://scripts/unit_layout.gd").lane_position(main.map.route.curve,j+0.05,s.lane_offset)
      check(near_after.distance_to(near_before)<0.5,"Continuous lane position through bends")
     last=s.position
   s.progress=500
   var before:float=s.progress
   s._process(0.2)
   check(is_equal_approx(s.progress-before,s.base_speed*0.2),"Forward speed unchanged")
   check(is_equal_approx(s.bar.scale.x*s.scale.x,1.0),"Knowledge bar readable at original scale")
   s.free()
  offsets.sort()
  check(offsets[-1]-offsets[0]>20,"Groups use different lanes")
  main.game.gold=200
  var slot=main.map.slots.get_child(2)
  main.build(slot,"assistant")
  var post=slot.tower
  for a in post.assistants:check(a.scale==Vector2(0.7,0.7),"Assistants70percent")
  check(post.assistants[0].home_position().distance_to(post.assistants[1].home_position())>20,"Assistants retain rally spread")
  main.free()
 print("UNIT LAYOUT: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
