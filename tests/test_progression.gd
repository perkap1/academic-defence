extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(root.has_node("Progression"),"Progression autoload exists")
	if not root.has_node("Progression"):
		quit(1)
		return
	var progress = root.get_node("Progression")
	check(not progress.persist_enabled,"Tests cannot modify player save")
	progress.completed_levels.clear()
	progress.bookworm_seen = false
	var world = load("res://scenes/world_map.tscn").instantiate()
	root.add_child(world)
	check(world.can_open_level(2),"Map3 available from start")
	progress.complete_level(1)
	check(world.can_open_level(2),"Map3 remains available")
	var main = load("res://scenes/main_map2.tscn").instantiate()
	root.add_child(main)
	main.game.finish(true)
	check(world.can_open_level(2),"Map2 victory unlocks Map3")
	main.free()
	world.free()
	world = load("res://scenes/world_map.tscn").instantiate()
	root.add_child(world)
	check(not world.level_buttons[2].disabled,"Unlocked button selectable")
	world.free()
	main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	check(main.ui.instruction_panel.position == Vector2(860,202),"Instructions clear upper entrance")
	main.show_bookworm_tutorial()
	check(progress.bookworm_seen and main.ui.bookworm_tutorial.visible,"First Bookworm introduces shield")
	main.ui.bookworm_tutorial.hide()
	main.show_bookworm_tutorial()
	check(not main.ui.bookworm_tutorial.visible,"Introduction only once")
	main.free()
	var temporary = load("res://scripts/progression.gd").new()
	temporary.save_path = "user://map3_regression_only.cfg"
	temporary.complete_level(2)
	temporary.mark_bookworm_seen()
	var restored = load("res://scripts/progression.gd").new()
	restored.save_path = temporary.save_path
	restored.load_progress()
	check(2 in restored.completed_levels and restored.bookworm_seen,"Progress and introduction survive save/reload")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary.save_path))
	temporary.free()
	restored.free()
	print("PROGRESSION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
