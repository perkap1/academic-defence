extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var stage=Node2D.new()
 root.add_child(stage)
 var directions=["front","side","back"]
 for row in range(3):
  for i in range(6):
   var student=load("res://scenes/student.tscn").instantiate()
   stage.add_child(student)
   student.position=Vector2(140+i*200,230+row*210)
   student.sprite.texture=student.frames[directions[row]][i]
   student.sprite.flip_h=false
   student.bar.hide()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("../AcademicDefence-normal-fixed.png")
 print("NORMAL VISUAL: rendered all 18 fixed-scale poses")
 stage.queue_free()
 quit()
