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
	check(FileAccess.file_exists("res://scenes/bookworm.tscn"),"Bookworm variant exists")
	if not FileAccess.file_exists("res://scenes/bookworm.tscn"):
		quit(1)
		return
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var student = load("res://scenes/bookworm.tscn").instantiate()
	main.map.route.add_child(student)
	student.progress = 550
	student.update_lane_position()
	check(student.base_speed == 85 and student.books == 3,"Normal speed and 3 shields")
	for amount in [20,60,999]:
		var before: Vector2 = student.global_position
		var progress_before: float = student.progress
		var shield_before: int = student.books
		student.teach(amount)
		check(student.books == shield_before-1 and student.knowledge == 0,"Any strength removes one book, zero Knowledge")
		check(student.global_position == before and student.progress == progress_before,"Reaction does not move/reset unit")
		check(main.map.effects.get_child_count() == 4-shield_before,"One reaction for each removed book")
		check(student.frames.front[0].get_size() == Vector2(180,200),"State maintains same canvas")
	student.teach(20)
	check(student.knowledge == 20,"Next hit after last book teaches normally")
	student.apply_slow(2,0.3)
	var before: float = student.progress
	student._process(1)
	check(is_equal_approx(student.progress-before,59.5),"Slow works with Bookworm")
	student.resolved.connect(main.student_resolved)
	var gold: int = main.game.gold
	student.teach(80)
	check(student.done and main.game.gold == gold+10,"Normal graduation reward after shield gone")
	main.free()
	print("BOOKWORM: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
