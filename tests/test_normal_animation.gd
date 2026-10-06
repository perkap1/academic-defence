extends SceneTree
func _initialize():
 call_deferred("run")
func run():
 var student=load("res://scenes/student.tscn").instantiate()
 root.add_child(student)
 var failures=0
 for direction in ["front","side","back"]:
  for frame in student.frames[direction]:
   if not frame is AtlasTexture or frame.get_size()!=Vector2(300,320):
    failures+=1
 if student.sprite.scale!=Vector2(0.28,0.28): failures+=1
 if student.sprite.offset!=Vector2(-150,-310): failures+=1
 print("NORMAL ANIMATION: 20 checks, %d failures"%failures)
 student.free()
 quit(1 if failures else 0)
