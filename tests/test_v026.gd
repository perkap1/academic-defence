extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.waves.has_method("get_next_wave_preview"),"Preview reads actual spawn planning")
 if not main.waves.has_method("get_next_wave_preview"):main.free();finish();return
 var site=main.map.slots.get_child(0);site.set_blocker("");main.game.gold=1000;main.build(site,"assistant");main.select_slot(site)
 var rally:Vector2=site.tower.rally_point
 var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=main.wave_preview.icons[0].get_global_rect().get_center()
 main._input(click)
 check(main.selected_tower_slot==site and site.tower.rally_point==rally,"Preview click preserves tower selection and assistant rally")
 main.clear_selection()
 var touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=true;touch.position=root.get_final_transform()*click.position
 Input.parse_input_event(touch)
 await process_frame
 touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=false;touch.position=root.get_final_transform()*click.position
 Input.parse_input_event(touch)
 await process_frame
 check(main.wave_preview.panel.visible and main.wave_preview.pinned,"Native touch events open preview")
 for pressed in [true,false]:
  touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=pressed;touch.position=root.get_final_transform()*click.position
  Input.parse_input_event(touch);await process_frame
 check(not main.wave_preview.panel.visible,"Native second tap closes preview")
 for position in [Vector2(300,400),click.position]:
  var motion=InputEventMouseMotion.new();motion.position=root.get_final_transform()*position;motion.global_position=motion.position
  Input.parse_input_event(motion);await process_frame
 check(main.wave_preview.panel.visible and not main.wave_preview.pinned,"Native mouse hover opens preview")
 var motion=InputEventMouseMotion.new();motion.position=root.get_final_transform()*Vector2(300,400);motion.global_position=motion.position
 Input.parse_input_event(motion);await process_frame
 check(not main.wave_preview.panel.visible,"Native mouse leave hides preview")
 main.wave_preview.hide_panel()
 for scene in ["main","main_map2","main_map3","main_map4","main_map5"]:
  var level=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(level);level.process_mode=Node.PROCESS_MODE_DISABLED
  for next_wave in range(1,level.waves.counts.size()+1):
   level.waves.wave=next_wave-1;level.waves.active=false
   var old_wave:int=level.waves.wave
   seed(2606);var expected_random=randi();seed(2606)
   var preview:Dictionary=level.waves.get_next_wave_preview()
   check(randi()==expected_random,"Preview does not consume RNG")
   check(level.waves.wave==old_wave,"Preview does not mutate current wave")
   level.waves.wave=next_wave
   var expected={}
   for index in range(level.waves.counts[next_wave-1]):
    var route:int=level.waves.get_spawn_route(index);var kind:String=level.waves.get_spawn_kind(index)
    if not expected.has(route):expected[route]={}
    expected[route][kind]=expected[route].get(kind,0)+1
   check(preview==expected,"Exact planned composition by entry %s wave%d"%[scene,next_wave])
   level.waves.wave=old_wave;level.update_ui()
   check(level.wave_preview.icons.size()==preview.size(),"Only active entrance icons")
   for route in preview:
    level.wave_preview.show_entry(route)
    check(level.wave_preview.panel.visible,"Hover/tap panel opens")
    var panel_rect:Rect2=level.wave_preview.panel.get_global_rect()
    check(Rect2(0,190,1672,941).encloses(panel_rect),"Panel stays inside play area")
    for kind in preview[route]:check(level.wave_preview.row_labels[kind].text.ends_with("x %d"%preview[route][kind]),"Exact count in each enemy row")
    var icon_rect:Rect2=level.wave_preview.icons[route].get_global_rect()
    for slot in level.map.slots.get_children():check(not icon_rect.grow(65).has_point(slot.global_position),"Icon does not intercept build slot hit area")
    level.wave_preview.icons[route].mouse_exited.emit()
    check(not level.wave_preview.panel.visible,"Mouse leave closes hover")
    level.wave_preview.touch_input=true;level.wave_preview.icons[route].pressed.emit()
    check(level.wave_preview.panel.visible and level.wave_preview.pinned,"Touch press pins information")
    level.wave_preview.icons[route].pressed.emit()
    check(not level.wave_preview.panel.visible,"Second touch closes information")
    level.wave_preview.show_entry(route)
    var total:int=preview[route].values().reduce(func(a,b):return a+b,0)
    check(level.wave_preview.total_label.text=="TOTAL: %d STUDENTS"%total,"Exact per-entry total")
   level.waves.start_wave()
   check(level.wave_preview.icons.is_empty() and not level.wave_preview.panel.visible,"Starting wave immediately hides preview")
   level.waves.active=false
  level.waves.wave=level.waves.counts.size();level.update_ui()
  check(level.wave_preview.icons.is_empty(),"Nothing after final wave")
  level.free()
 main.free();finish()
func finish():
 print("V026: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
