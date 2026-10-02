extends "res://tests/test_visual.gd"
func run() -> void:
 for scene in ["main","main_map2"]:
  var main=load("res://scenes/"+scene+".tscn").instantiate()
  root.add_child(main)
  current_scene=main
  await process_frame
  await physics_frame
  var layer=main.map.get_node("Environment")
  var frames_before := []
  var positions := []
  for sprite in layer.get_children():
   frames_before.append(sprite.frame)
   positions.append(sprite.position)
  await capture("AcademicDefence-v007-"+scene+"-environment.png")
  await create_timer(0.7).timeout
  var changed := 0
  for i in range(layer.get_child_count()):
   var sprite=layer.get_child(i)
   changed += int(sprite.frame != frames_before[i])
   check(sprite.position==positions[i],"Only pixels animate; nodes stay fixed")
  check(changed>0,"Ambient loops advance on "+scene)
  await capture("AcademicDefence-v007-"+scene+"-environment-next.png")
  paused = true
  var paused_frame = layer.get_child(0).frame
  await create_timer(0.5).timeout
  check(layer.get_child(0).frame == paused_frame,"Ambient animation respects pause")
  paused = false
  main.build(main.map.slots.get_child(4),"book")
  main.build(main.map.slots.get_child(2),"assistant")
  main.waves.start_wave()
  await create_timer(3).timeout
  check(main.waves.active,"Wave works with visual layer")
  await capture("AcademicDefence-v007-"+scene+"-gameplay.png")
  main.queue_free()
  await process_frame
 print("VISUAL V007: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)


