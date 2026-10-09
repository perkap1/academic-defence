extends SceneTree
func _initialize():call_deferred("run")
func run():
 for id in [2,3]:
  var main=load("res://scenes/main_map%d.tscn"%id).instantiate()
  root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  var routes=main.map.get_routes()
  for i in range(3):
   var s=load("res://scenes/student.tscn" if i==0 else "res://scenes/snack_monster.tscn").instantiate()
   routes[i%routes.size()].add_child(s)
   s.progress=720+i*115;s.lane_offset=0;s.update_lane_position();s._process(0)
   if i==2:s.teach(200)
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-snack-map%d.png"%id))
  main.free()
 quit()
