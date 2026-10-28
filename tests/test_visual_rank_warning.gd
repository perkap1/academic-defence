extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.waves.variant_rng.seed=3405;main.waves.wave=21;main.update_ui()
 var ranks:Dictionary=main.waves.get_next_wave_ranks();main.wave_preview.show_entry(ranks.keys()[0])
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/ranked-wave-warning.png")
 main.free();quit()
