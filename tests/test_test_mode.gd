extends "res://tests/test_integration.gd"
func run():
 var progress=root.get_node("Progression")
 check(progress.has_method("set_test_mode"),"World-map test mode setting exists")
 check(load("res://scripts/pe_teacher.gd").ROLL_DISTANCES==[240.0,350.0,480.0],"Medicine ball rolls exactly twice as far on all levels")
 if failures:print("TEST MODE: %d checks, %d failures"%[checks,failures]);quit(1);return
 var previous_mode:bool=progress.test_mode
 var previous_stars:Dictionary=progress.best_stars.duplicate()
 var previous_completed:Array=progress.completed_levels.duplicate()
 progress.set_test_mode(false)
 var world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 check(not world.test_mode_button.button_pressed and world.test_mode_button.text.contains("AV"),"World map shows normal mode initially")
 world.test_mode_button.button_pressed=true
 check(progress.test_mode and world.test_mode_button.text.contains("PÅ"),"World map toggle enables test mode")
 for id in range(1,6):
  var main=load("res://scenes/%s.tscn"%("main" if id==1 else "main_map%d"%id)).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  check(main.game.gold==2000 and main.game.test_mode,"All five maps start test mode with2000KP")
  check(main.ui.test_mode_label.visible,"HUD marks active test mode")
  main.game.gold-=150;main.update_ui()
  check(main.game.gold==1850,"UI updates cannot refill test KP")
  main.free()
 world.free()
 world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 check(world.test_mode_button.button_pressed,"Mode survives returning to world map")
 world.test_mode_button.button_pressed=false
 check(not progress.test_mode and world.test_mode_button.text.contains("AV"),"World map toggle disables test mode")
 for id in range(1,6):
  var main=load("res://scenes/%s.tscn"%("main" if id==1 else "main_map%d"%id)).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  check(main.game.gold==200 and not main.game.test_mode,"Disabling restores normal200KP on every map")
  check(not main.ui.test_mode_label.visible,"Normal mode hides test marker")
  main.free()
 check(progress.best_stars==previous_stars and progress.completed_levels==previous_completed,"Switching modes preserves saved progress")
 world.free()
 var config=load("res://scripts/progression.gd").new();root.add_child(config)
 config.save_path="user://test_mode_regression.cfg";config.persist_enabled=true
 config.set_test_mode(true);config.test_mode=false;config.load_progress()
 check(config.test_mode,"Test mode preference survives saving and loading")
 var old=ConfigFile.new();old.set_value("progress","completed_levels",[1]);old.save(config.save_path)
 config.load_progress();check(not config.test_mode and config.get_stars(1)==1,"Older saves default to normal mode and retain progress")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(config.save_path));config.free()
 progress.set_test_mode(previous_mode)
 print("TEST MODE: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
