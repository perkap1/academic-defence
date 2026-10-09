extends SceneTree
func _initialize():call_deferred("run")
func run():
 var stage=Node2D.new();root.add_child(stage)
 var frames=load("res://scripts/snack_frames.gd").create()
 for row in range(3):
  for i in range(10):
   var sprite=Sprite2D.new()
   sprite.texture=frames[["front","side","back"][row]][i]
   sprite.centered=false;sprite.offset=Vector2(-90,-210)
   sprite.position=Vector2(80+i*158,280+row*280)
   sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
   stage.add_child(sprite)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-snack-frames.png"))
 stage.free();quit()
