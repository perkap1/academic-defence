extends SceneTree

var checks := 0
var failures := 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: " + description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not FileAccess.file_exists("res://scripts/blackboard_tower.gd"):
		check(false, "Blackboard Tower is not implemented yet")
		quit(1)
		return
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var slot = main.map.slots.get_child(1)
	main.build(slot, "blackboard")
	check(slot.occupied and main.game.gold == 100, "Blackboard costs 100")
	check(slot.tower.tower_type == "blackboard", "Build selects Blackboard scene")
	main.build(slot, "book")
	check(main.game.gold == 100, "Cannot replace occupied slot")
	main.game.gold = 99
	main.build(main.map.slots.get_child(2), "blackboard")
	check(not main.map.slots.get_child(2).occupied and main.game.gold == 99, "Blackboard rejects insufficient funds")
	check(not main.game.try_build(main.map.slots.get_child(2), "invalid"), "Unknown tower rejected")
	var board = slot.tower
	check(board.teaching_range < 260 and board.fire_interval > 1 and board.knowledge_per_hit < 20, "Board trades single-target strength for area")
	var near := []
	for offset in [Vector2(0,80), Vector2(35,90), Vector2(60,95), Vector2(200,0)]:
		var student = load("res://scenes/student.tscn").instantiate()
		main.map.route.add_child(student)
		student.position = slot.position + offset
		near.append(student)
	board._process(0.1)
	check(near[0].knowledge == 15 and near[1].knowledge == 15 and near[2].knowledge == 15, "Pulse teaches three nearby students")
	check(near[3].knowledge == 0, "Pulse leaves student outside AoE unchanged")
	board._process(0.1)
	check(near[0].knowledge == 15, "Pulse respects attack interval")
	for sex in ["boy", "girl"]:
		var pe = load("res://scenes/student.tscn").instantiate()
		pe.configure("pe", sex)
		main.map.route.add_child(pe)
		check(is_equal_approx(pe.speed, 114.75) and pe.MAX_KNOWLEDGE == 100, "PE %s speed and knowledge" % sex)
		check(pe.frames["side"][2].resource_path.contains("pe_%s" % sex), "PE %s correct sheet" % sex)
		pe._process(1.0)
		check(is_equal_approx(pe.progress, 114.75), "PE movement comes from route speed")
		pe.teach(20)
		check(pe.bar.value == 20, "PE uses live progress bar")
		for frames in pe.frames.values():
			for texture in frames:
				check(texture.get_size() == Vector2(80,90), "PE frame size stable")
	for texture in board.frames:
		check(texture.get_size() == Vector2(500,500), "Science atlas canvas stable")
	main.free()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	for wave in range(7):
		check(main.waves.start_wave(), "Mixed wave can start")
		main.waves._process(100)
		var expected_pe: int = [0,0,2,3,4,5,6][wave]
		var count_pe := 0
		for student in main.waves.students:
			if student.student_type == "pe":
				count_pe += 1
		check(count_pe == expected_pe, "Wave %d PE distribution" % (wave+1))
		check(main.waves.students.size() == [4,6,8,11,14,17,20][wave], "Wave %d total" % (wave+1))
		for student in main.waves.students.duplicate():
			if student.student_type=="bookworm":
				for hit in range(3): student.teach(100)
			student.teach(100)
	check(main.game.won, "Mixed-wave full completion reaches victory")
	print("V0.002: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
