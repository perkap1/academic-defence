extends "res://tests/test_visual.gd"
func run() -> void:
 var main=load("res://scenes/main_map2.tscn").instantiate()
 root.add_child(main)
 current_scene=main
 await process_frame
 var slot=main.map.slots.get_child(2)
 await click_at(slot.global_position)
 check(main.ui.build_menu.visible and not main.ui.assistant_button.disabled,"Assistant available in centered radial menu")
 check(main.ui.build_menu.position+Vector2(220,220)==slot.global_position,"Third radial choice does not shift center")
 await capture("AcademicDefence-v006-radial.png")
 await click_at(main.ui.assistant_button.get_global_rect().get_center())
 check(slot.occupied and slot.tower.tower_type=="assistant" and main.game.gold==80,"Actual radial input builds Assistant for120")
 var post=slot.tower
 await click_at(slot.global_position)
 var old_rally:Vector2=post.rally_point
 var new_rally:Vector2=main.map.route.to_global(main.map.route.curve.sample_baked(main.map.route.curve.get_closest_offset(main.map.route.to_local(old_rally))-30))
 await click_at(new_rally)
 check(post.rally_point.distance_to(new_rally)<1 and main.selected_tower_slot==slot,"Actual road input relocates rally and retains selection")
 main.clear_selection()
 main.process_mode=Node.PROCESS_MODE_DISABLED
 for a in post.assistants:
  a._process(3)
  for kind in a.frames:
   for direction in a.frames[kind]:
    for frame in a.frames[kind][direction]: check(frame.get_size()==Vector2(60,88),"Identical sprite canvases across walk/teach/idle")
 var students=[]
 for i in range(3):
  var s=load("res://scenes/student.tscn").instantiate()
  s.configure("normal" if i==0 else "pe","girl" if i==2 else "boy")
  main.map.route.add_child(s)
  s.progress=main.map.route.curve.get_closest_offset(main.map.route.to_local(post.rally_point))+i*55-25
  s.resolved.connect(main.student_resolved)
  students.append(s)
 for a in post.assistants: a._process(.01)
 for a in post.assistants: a._process(1)
 for a in post.assistants: a._process(.4)
 main.select_slot(slot)
 check(students[0].assistant_hold and students[1].assistant_hold and not students[2].assistant_hold,"Two teach interactions and third student passes")
 check(post.assistants[0].teaching_effect.visible and post.assistants[1].teaching_effect.visible,"Teaching art visible between each pair")
 check(post.marker.visible,"Selected post displays supplied rally marker")
 await capture("AcademicDefence-v006-assistants.png")
 main.process_mode=Node.PROCESS_MODE_INHERIT
 main.toggle_pause()
 var elapsed:float=post.assistants[0].elapsed
 await create_timer(.15,true).timeout
 check(post.assistants[0].elapsed==elapsed,"Pause freezes teaching and Knowledge")
 main.toggle_pause()
 main.select_slot(slot)
 await click_at(main.ui.sell_button.get_global_rect().get_center())
 check(not slot.occupied and main.game.gold==140,"Actual SELL input refunds60")
 for s in students: check(not s.assistant_hold and s.teacher==null,"Selling clears every student hold")
 await process_frame
 check(not is_instance_valid(post),"Sold post and owned assistant nodes removed")
 print("VISUAL V006: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)
