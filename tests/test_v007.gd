extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  print("FAIL: " + message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 for scene in ["main", "main_map2"]:
  var main = load("res://scenes/"+scene+".tscn").instantiate()
  root.add_child(main)
  # Unit fixture: isolate tower/combat behavior from paid site clearing.
  for site in main.map.slots.get_children(): site.set_blocker("")
  main.process_mode = Node.PROCESS_MODE_DISABLED
  check(main.map.has_node("Environment"), scene+" has ambient layer")
  if main.map.has_node("Environment"):
   var layer = main.map.get_node("Environment")
   check(layer.z_index == -9, "Behind gameplay above background")
   var kinds := {}
   for sprite in layer.get_children():
    check(sprite is AnimatedSprite2D, "Lightweight animation")
    check(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Sharp pixels")
    check(sprite.sprite_frames.get_frame_count("loop") == 4, "Four frames")
    check(sprite.sprite_frames.get_animation_loop("loop"), "Continuous loop")
    check(sprite.get_child_count() == 0, "Visual only, no collider")
    kinds[sprite.get_meta("kind")] = true
   for kind in ["water", "bush", "leaves", "plant"]:
    check(kinds.has(kind), "Includes "+kind)
   check(kinds.has("waterfall") == (scene == "main_map2"), "Waterfalls only where map has falls")
  check(main.map.slots.get_child_count() == (9 if scene == "main" else 8), "Build slots preserved")
  main.free()
 print("V007: %d checks, %d failures" % [checks, failures])
 quit(1 if failures else 0)
