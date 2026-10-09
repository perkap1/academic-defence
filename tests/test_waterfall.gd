extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  print("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var map1=load("res://scenes/main.tscn").instantiate()
 root.add_child(map1)
 map1.process_mode=Node.PROCESS_MODE_DISABLED
 check(not map1.map.has_node("AnimatedWaterfall"),"Map1 unchanged")
 map1.free()
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 # Unit fixture: isolate tower/combat behavior from paid site clearing.
 for site in main.map.slots.get_children(): site.set_blocker("")
 main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.map.has_node("AnimatedWaterfall"),"Map2 uses reusable waterfall scene")
 if main.map.has_node("AnimatedWaterfall"):
  var waterfall=main.map.get_node("AnimatedWaterfall")
  check(waterfall is AnimatedSprite2D,"Uses native animated sprite")
  check(waterfall.sprite_frames.get_frame_count("flow")==6,"Six supplied frames")
  check(waterfall.sprite_frames.get_animation_loop("flow"),"Continuous loop")
  check(waterfall.sprite_frames.get_animation_speed("flow")==7.0,"Seven FPS")
  check(waterfall.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"Nearest pixels")
  check(not waterfall.centered,"Fixed top-left pivot")
  check(waterfall.get_child_count()==0,"Visual only with no collision")
  check(waterfall.z_index==-8,"Behind gameplay")
  var atlas=waterfall.sprite_frames.get_frame_texture("flow",0)
  for f in range(6):
   var texture=waterfall.sprite_frames.get_frame_texture("flow",f)
   check(texture is AtlasTexture,"Frames use sheet regions")
   check(texture.region.size==atlas.region.size,"Identical frame canvas")
   check(texture.region.position==atlas.region.position+Vector2(362*f,0),"Correct cell spacing")
  check(waterfall.material.get_shader_parameter("map_texture")==main.map.get_node("Background").texture,"Mask uses current map")
  check(waterfall.material.get_shader_parameter("map_origin")==waterfall.position,"Mask follows placement")
  var copy=load("res://scenes/AnimatedWaterfall.tscn").instantiate()
  copy.position=Vector2(1200,300)
  copy.scale=Vector2(0.5,0.5)
  main.map.add_child(copy)
  check(copy.material!=waterfall.material,"Copies own independent materials")
  check(copy.material.get_shader_parameter("map_origin")==copy.position,"Copy uses its own origin")
  check(copy.material.get_shader_parameter("map_x_axis")==Vector2(0.5,0),"Copy uses its own scale")
  check(waterfall.material.get_shader_parameter("map_origin")==waterfall.position,"Configuring copy preserves original")
  copy.free()
  var old_effects := 0
  for sprite in main.map.get_node("Environment").get_children():
   if sprite.get_meta("kind")=="waterfall":
    old_effects+=1
    check(sprite.position==Vector2(85,680),"Old top-right overlay removed")
  check(old_effects==1,"Bottom-left effect preserved")
 check(main.map.slots.get_child_count()==8,"All build spots preserved")
 check(main.map.route.curve.point_count==main.map.route_points.size(),"Route preserved")
 main.free()
 print("WATERFALL: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
