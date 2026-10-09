extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate()
 root.add_child(main)
 main.process_mode=Node.PROCESS_MODE_DISABLED
 main.select_slot(main.map.slots.get_child(6))
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v018-clear.png"))
 main.ui.close_build_menu()
 main.map.slots.get_child(0).set_hover(true)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v018-sites.png"))
 main.free();quit()
