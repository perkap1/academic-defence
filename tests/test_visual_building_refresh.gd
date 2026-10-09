extends SceneTree
func _initialize():call_deferred("run")
func run():
 var stage=Node2D.new()
 root.add_child(stage)
 for row in range(5):
  var frames=[]
  var caption=""
  if row<3:
   caption=["Study Hall","Library","Scholarship Office"][row]
   frames=load("res://scripts/building_frames.gd").economy(["study","library","scholarship"][row])
  elif row==3:
   caption="Post idle"
   frames=load("res://scripts/building_frames.gd").post_idle()
  else:
   caption="Pointing: R DR D DL L UL U UR"
   for direction in ["right","down_right","down","down_left","left","up_left","up","up_right"]:
    frames.append(load("res://scripts/building_frames.gd").pointing(direction)[0])
  var label=Label.new()
  label.text=caption
  label.position=Vector2(15,25+row*215)
  stage.add_child(label)
  for i in range(frames.size()):
   var sprite=Sprite2D.new()
   sprite.texture=frames[i]
   sprite.centered=false
   sprite.offset=Vector2(-180,-290)
   sprite.scale=Vector2.ONE*0.45
   sprite.position=Vector2(100+i*166,195+row*215)
   stage.add_child(sprite)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-building-frames.png"))
 stage.free()
 quit()
