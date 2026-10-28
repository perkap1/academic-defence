extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.waves.wave=8
 var entry:=-1
 for seed_value in range(200):
  main.waves.variant_rng.seed=seed_value;main.waves.planned_waves.erase(9)
  var ranks:Dictionary=main.waves.get_next_wave_ranks()
  for candidate in ranks:
   if ranks[candidate].size()==2:entry=candidate;break
  if entry>=0:break
 main.update_ui();main.wave_preview.show_entry(entry)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/third-wave-warning.png")
 main.free();quit()
