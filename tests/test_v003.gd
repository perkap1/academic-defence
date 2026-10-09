extends SceneTree

var checks := 0
var failures := 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		print("FAIL: " + description)

func _initialize() -> void:
	call_deferred("run")

func battle(scene: String = "main"):
	var main = load("res://scenes/%s.tscn" % scene).instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	return main

func run() -> void:
	var main = battle()
	var normal = load("res://scenes/student.tscn").instantiate()
	main.map.route.add_child(normal)
	check(normal.has_method("apply_slow"), "Students support temporary Blackboard slow")
	if normal.has_method("apply_slow"):
		for kind in ["normal", "pe"]:
			for sex in ["boy", "girl"]:
				var student = load("res://scenes/student.tscn").instantiate()
				student.configure(kind, sex)
				main.map.route.add_child(student)
				var base := 85.0 if kind == "normal" else 114.75
				student.apply_slow()
				check(is_equal_approx(student.speed, base * 0.70), "30 percent slow: %s %s" % [kind,sex])
				student._process(1.0)
				check(is_equal_approx(student.progress, base * 0.70), "Slow affects actual route movement")
				student.apply_slow()
				check(is_equal_approx(student.speed, base * 0.70), "Repeated hit refreshes without stacking")
				student._process(1.5)
				check(is_equal_approx(student.speed, base * 0.70), "Refresh extends timer")
				var before: float = student.progress
				student._process(1.0)
				check(is_equal_approx(student.progress - before, base * 0.85), "Expiry frame splits slowed and normal movement")
				check(is_equal_approx(student.speed, base), "Expiry restores original normal or PE speed")
				student._process(0.5)
				check(is_equal_approx(student.progress - before, base * 1.35), "Movement remains normal after expiry")
				student.complete(true)
				student.apply_slow()
				check(is_equal_approx(student.speed, base), "Completed students ignore slow")
	var slot = main.map.slots.get_child(1)
	main.build(slot,"blackboard")
	var near := []
	for offset in [Vector2(0,80),Vector2(35,90),Vector2(60,95),Vector2(200,0)]:
		var student = load("res://scenes/student.tscn").instantiate()
		student.configure("pe" if near.size() == 1 else "normal")
		main.map.route.add_child(student)
		student.position = slot.position + offset
		near.append(student)
	normal.complete(true)
	slot.tower._process(0.1)
	check(near[0].knowledge == 15 and near[1].knowledge == 15 and near[2].knowledge == 15, "Blackboard AoE teaches entire nearby group")
	check(is_equal_approx(near[0].speed,59.5) and is_equal_approx(near[1].speed,80.325), "Blackboard AoE slows normal and PE")
	check(near[3].knowledge == 0 and near[3].speed == 85.0, "AoE leaves outside student unchanged")
	check(main.has_method("sell") and main.game.has_method("try_sell"), "Tower selling implemented")
	if main.has_method("sell"):
		main.game.gold = 200
		check(main.sell(slot), "Blackboard can be sold")
		check(main.game.gold == 250 and not slot.occupied and slot.tower == null, "Blackboard refunds exactly 50 and frees slot")
		check(not main.sell(slot) and main.game.gold == 250, "Repeated sale never pays twice")
		main.build(slot,"book")
		check(main.game.gold == 180 and slot.occupied, "Same slot accepts rebuilt Book")
		check(main.sell(slot) and main.game.gold == 215, "Book refunds exactly 35")
		var foreign = load("res://scenes/build_slot.tscn").instantiate()
		root.add_child(foreign)
		foreign.occupied = true
		check(not main.sell(foreign) and main.game.gold == 215, "Foreign slot cannot mint refunds")
		foreign.free()
		main.build(slot,"book")
		main.game.finished = true
		check(not main.sell(slot) and main.game.gold == 145, "Finished game rejects sale")
	main.free()
	main = battle()
	check(main.has_method("clear_selection"), "Exclusive tower selection implemented")
	if main.has_method("clear_selection"):
		var a = main.map.slots.get_child(1)
		var b = main.map.slots.get_child(2)
		main.build(a,"book")
		main.build(b,"blackboard")
		main.select_slot(a)
		check(a.tower.show_range and main.ui.tower_panel.visible, "Selected tower displays range and sell panel")
		a.set_hover(false)
		check(a.tower.show_range, "Selection persists after pointer leaves tower")
		b.set_hover(true)
		check(not b.tower.show_range, "Hover cannot create second range")
		main.select_slot(b)
		check(not a.tower.show_range and b.tower.show_range, "Other tower replaces selected range")
		main.select_slot(main.map.slots.get_child(3))
		check(not a.tower.show_range and not b.tower.show_range and not main.ui.tower_panel.visible, "Empty slot deselects old tower")
		main.select_slot(a)
		main.clear_selection()
		check(not a.tower.show_range and not main.ui.tower_panel.visible, "Deselect closes range and tower panel")
	main.free()
	check(FileAccess.file_exists("res://scenes/main_map2.tscn"), "Map 2 exists as separate playable scene")
	if FileAccess.file_exists("res://scenes/main_map2.tscn"):
		main = battle("main_map2")
		check(main.map.slots.get_child_count() == 8,"Map 2 exactly eight slots")
		var positions := [Vector2(588,248),Vector2(406,382),Vector2(608,558),Vector2(950,541),Vector2(985,323),Vector2(1204,483),Vector2(1459,413),Vector2(1389,615)]
		for i in range(8):
			check(main.map.slots.get_child(i).position.distance_to(positions[i]) < 2,"Slot aligns with circle %d" % i)
		var checkpoints := [Vector2(100,294),Vector2(450,471),Vector2(768,279),Vector2(986,446),Vector2(1194,579),Vector2(1510,537)]
		for p in checkpoints:
			check(main.map.route.curve.get_closest_point(p).distance_to(p) < 35,"Map2 route follows road at %s" % p)
		for wave in range(12):
			check(main.waves.start_wave(),"Map2 wave %d starts" % (wave+1))
			main.waves._process(100)
			var pe := 0
			for student in main.waves.students:
				if student.student_type == "pe": pe += 1
			check(main.waves.students.size() == main.waves.counts[wave],"Map2 total students per wave")
			check(pe == [0,0,2,3,5,5,7,7,9,10,10,12][wave],"Map2 PE distribution")
			for student in main.waves.students.duplicate():
				if student.student_type=="bookworm":
					for hit in range(3): student.teach(100)
				if student.student_type=="snack":
					student.teach(200);student._process(2);student.teach(300)
				else:student.teach(100)
		check(main.game.won and main.waves.wave == 12,"Map2 victory waits for wave12")
		check(main.game.graduated == main.waves.counts.reduce(func(a,b):return a+b,0),"All Map2 students resolve once")
		check(main.ui.wave_label.text == "12 / 12","Map2 HUD uses twelve waves")
		main.free()
	print("V0.003: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
