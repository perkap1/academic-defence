extends SceneTree
func _initialize():call_deferred("run")
func run():
 for scene in ["main","main_map2"]:
  var main=load("res://scenes/%s.tscn"%scene).instantiate()
  root.add_child(main)
  main.game.gold=1000
  main.build(main.map.slots.get_child(2),"assistant")
  main.select_slot(main.map.slots.get_child(2))
  await process_frame
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-assistant-banner-%s.png"%scene))
  main.queue_free()
  await process_frame
 print("ASSISTANT VISUAL: both maps rendered")
 quit()
