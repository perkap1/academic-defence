extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.waves.wave=15;main.waves.active=true;main.waves.remaining=1
 for route in main.map.get_routes():
  for i in range(9):
   var pilot=load("res://scenes/paper_plane_pilot.tscn").instantiate();route.add_child(pilot);pilot.progress=250+i*140;pilot.update_lane_position()
   pilot.direction="side";pilot.sprite.texture=pilot.frames.side[i]
 main.update_ui()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v023-pilots.png"))
 main.free();quit()
