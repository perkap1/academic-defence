extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.waves.variant_rng.seed=2707;main.waves.wave=21;main.update_ui();main.wave_preview.show_entry(2)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v027-preview.png"))
 main.free();quit()
