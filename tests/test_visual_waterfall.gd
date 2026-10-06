extends "res://tests/test_visual.gd"
func run() -> void:
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 current_scene=main
 await process_frame
 await physics_frame
 var waterfall=main.map.get_node("AnimatedWaterfall")
 var origin:Vector2=waterfall.global_position
 var original_scale:Vector2=waterfall.scale
 var seen := {}
 for step in range(18):
  await waterfall.frame_changed
  check(waterfall.global_position==origin and waterfall.scale==original_scale,"Fixed origin/scale during playback")
  seen[waterfall.frame]=true
 check(seen.size()==6,"All six frames played in continuous loop")
 waterfall.stop()
 for f in range(6):
  waterfall.frame=f
  await process_frame
  await RenderingServer.frame_post_draw
  var image=root.get_texture().get_image()
  var zoom=image.get_region(Rect2i(1070,235,165,170))
  zoom.resize(660,680,Image.INTERPOLATE_NEAREST)
  check(zoom.save_png(ProjectSettings.globalize_path("res://../AcademicDefence-waterfall-frame%d.png"%f))==OK,"Render frame%d"%f)
 waterfall.play()
 await capture("AcademicDefence-waterfall-map2.png")
 paused=true
 var frame:int=waterfall.frame
 await create_timer(0.4).timeout
 check(waterfall.frame==frame,"Waterfall respects pause")
 paused=false
 main.build(main.map.slots.get_child(4),"book")
 main.waves.start_wave()
 await create_timer(4).timeout
 check(main.waves.active and main.waves.students.size()>0,"Gameplay runs under waterfall layer")
 await capture("AcademicDefence-waterfall-gameplay.png")
 main.queue_free()
 await process_frame
 print("VISUAL WATERFALL: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)
