extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: " + message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for scene in ["main", "main_map2"]:
		var main = load("res://scenes/%s.tscn" % scene).instantiate()
		root.add_child(main)
		# Unit fixture: isolate tower/combat behavior from paid site clearing.
		for site in main.map.slots.get_children(): site.set_blocker("")
		main.process_mode = Node.PROCESS_MODE_DISABLED
		check(main.game.TOWER_COSTS.has("economy"), "Study Hall available in existing project")
		if not main.game.TOWER_COSTS.has("economy"):
			main.free()
			continue
		main.game.gold = 5000
		var slot = main.map.slots.get_child(0)
		main.build(slot, "economy")
		var building = slot.tower
		check(main.game.gold == 4900 and slot.occupied, "Base costs 100")
		check(building.position == slot.position, "Build stays on slot")
		main.select_slot(slot)
		check(main.ui.tower_banner.visible and not building.show_range, "Study uses common banner without range")
		check(main.ui.specialization_buttons.size() == 2, "Two specialization choices")
		main.economy.complete_wave(1)
		check(main.game.gold == 4915 and building.active_time > 0, "Study income and active frame")
		main.economy.complete_wave(1)
		check(main.game.gold == 4915, "Wave cannot pay twice")
		check(main.specialize(slot, "library"), "Library specialization")
		check(slot.tower == building and building.position == slot.position, "Same node and position after specialization")
		check(main.game.gold == 4775 and building.get_sell_refund() == 120, "Specialization cost and refund")
		check(not main.specialize(slot, "research") and main.game.gold == 4775, "Exclusive branch cannot charge twice")
		main.economy.complete_wave(2)
		check(main.game.gold == 4820, "Library pays 45")
		check(main.sell(slot) and main.game.gold == 4940, "Sell returns half total investment")
		main.economy.complete_wave(3)
		check(main.game.gold == 4940, "Sold building has no income")
		main.build(slot, "economy")
		main.select_slot(slot)
		main.game.gold = 119
		main.update_ui()
		check(main.ui.specialization_buttons[0].disabled and not main.specialize(slot, "research"), "Unaffordable specialization disabled")
		main.game.gold = 5000
		check(not main.specialize(slot, "research"), "Removed branch cannot be purchased")
		main.sell(slot)
		var offices := []
		for index in [0, 1]:
			var office_slot = main.map.slots.get_child(index)
			main.build(office_slot, "economy")
			main.select_slot(office_slot)
			check(main.specialize(office_slot, "scholarship"), "Office specialization")
			offices.append(office_slot.tower)
		check(offices[1].show_range, "Office shows radius on selection")
		main.clear_selection()
		check(not offices[1].show_range and not main.ui.tower_banner.visible, "Deselect hides radius and banner")
		# Place two live offices in overlap to exercise global graduation ownership.
		offices[1].position = offices[0].position + Vector2(40, 0)
		main.waves.active = true
		main.economy.begin_wave(20)
		var students := []
		for i in range(12):
			var student = Node2D.new()
			main.map.add_child(student)
			student.global_position = offices[0].global_position
			students.append(student)
			var before: int = main.game.gold
			main.economy.student_graduated(student)
			main.economy.student_graduated(student)
			check(main.game.gold - before == 5, "Overlapping offices award student once")
		check(offices[0].wave_bonus == 50 and offices[1].wave_bonus == 10, "Office cap 50; eligible second office handles overflow")
		students[0].global_position += Vector2(1000, 0)
		main.economy.begin_wave(21)
		var before: int = main.game.gold
		main.economy.student_graduated(students[0])
		check(main.game.gold == before and offices[0].wave_bonus == 0, "New wave resets cap; outside radius earns nothing")
		main.economy.complete_wave(21)
		check(main.game.gold == before + 20, "Two Offices base income 10 each")
		# Exercise production graduation hooks for Normal and both PE variants.
		main.waves.wave = 0
		main.waves.active = false
		check(main.waves.start_wave() and offices[1].wave_bonus == 0, "Real wave start resets cap")
		main.waves.remaining = 1
		for data in [["normal","boy"],["pe","boy"],["pe","girl"]]:
			var student = load("res://scenes/student.tscn").instantiate()
			student.configure(data[0],data[1])
			main.map.route.add_child(student)
			student.set_process(false)
			student.global_position = offices[0].global_position
			student.resolved.connect(main.student_resolved)
			main.waves.students.append(student)
			before = main.game.gold
			student.teach(100)
			check(student.done and main.game.gold == before + 15, "Actual %s/%s graduation includes one Office bonus" % data)
			student.teach(100)
			check(main.game.gold == before + 15, "Repeated graduation cannot reward again")
		before = main.game.gold
		main.waves.wave = 30
		main.waves.remaining = 0
		main.waves.resolve_student(null)
		check(main.game.gold == before + 65, "Real wave completion gives 45 plus two Office incomes")
		main.waves.resolve_student(null)
		check(main.game.gold == before + 65, "Wave event cannot repeat payout")
		main.select_slot(main.map.slots.get_child(0))
		main.sell(main.map.slots.get_child(0))
		main.sell(main.map.slots.get_child(1))
		before = main.game.gold
		main.economy.complete_wave(31)
		check(main.game.gold == before, "Selling Offices clears all future income")
		main.game.finished = true
		main.economy.complete_wave(22)
		check(main.game.gold == before, "Finished game cannot pay")
		for student in students: student.free()
		main.free()
		await process_frame
	print("ECONOMY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
