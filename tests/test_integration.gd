extends SceneTree

var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run")

func simulate(main, seconds: float) -> void:
	var ticks := int(seconds * 30)
	for i in range(ticks):
		main.waves._process(1.0 / 30.0)
		for student in main.waves.students.duplicate():
			if is_instance_valid(student) and not student.done:
				student._process(1.0 / 30.0)
		for tower in main.map.towers.get_children():
			tower._process(1.0 / 30.0)
		for projectile in main.map.projectiles.get_children():
			if not projectile.is_queued_for_deletion():
				projectile._process(1.0 / 30.0)
		if main.game.finished:
			break

func run() -> void:
	if not FileAccess.file_exists("res://scenes/main.tscn"):
		check(false, "Playable loop is not implemented yet")
		quit(1)
		return
	var packed = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	check(main.waves.counts == [4, 6, 8, 11, 14, 17, 20], "Seven mixed wave counts")
	check(main.waves.start_wave(), "Wave one starts")
	check(not main.waves.start_wave(), "Overlapping wave rejected")
	simulate(main, 8)
	check(main.waves.active and main.waves.wave == 1, "Wave waits for students still on route")
	simulate(main, 60)
	check(not main.waves.active and main.game.lives == 6, "All four first-wave students escape")
	check(main.game.gold == 245, "Wave completion reward")
	main.waves.start_wave()
	simulate(main, 100)
	check(main.game.finished and not main.game.won and main.game.lives == 0, "No-tower run loses")
	check(not main.waves.start_wave(), "No wave after defeat")
	main.free()
	main = packed.instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	check(main.game.gold == 200 and main.game.lives == 10 and main.waves.wave == 0, "Fresh round resets state")
	check(main.map.towers.get_child_count() == 0, "Fresh round has no towers")
	# A normal-budget strategy: two towers first, reinvest between waves.
	var build_order := [4, 6, 2, 1, 7, 3, 0, 5, 8]
	for wave in range(7):
		for index in build_order:
			var slot = main.map.slots.get_child(index)
			if not slot.occupied and main.game.gold >= 70 + slot.get_clear_cost():
				if slot.is_blocked(): main.game.try_clear_site(slot)
				main.build(slot, "blackboard" if wave >= 2 and index in [2,1,3] and main.game.gold >= 100 else "book")
		check(main.waves.start_wave(), "Start wave %d in strategy run" % (wave + 1))
		simulate(main, 110)
		print("WAVE %d: lives=%d gold=%d graduates=%d" % [wave+1, main.game.lives, main.game.gold, main.game.graduated])
		check(not main.waves.active, "Wave %d resolves" % (wave+1))
		if main.game.finished:
			break
	check(main.game.finished and main.game.won and main.game.lives > 0, "Normal-budget strategy wins all seven waves")
	check(main.waves.wave == 7, "Victory follows seventh wave")
	check(main.game.graduated + main.game.escaped == 80, "All 80 students resolve exactly once")
	main.free()
	main = packed.instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	main.game.lives = 1
	main.waves.start_wave()
	main.waves._process(0.1)
	check(main.waves.remaining == 3, "Early defeat setup has unspawned students")
	var first = main.waves.students[0]
	first.progress = main.map.route.curve.get_baked_length() - 1
	first._process(0.1)
	check(main.game.finished and not main.waves.active and main.waves.remaining == 0, "Defeat stops spawning immediately")
	main.waves._process(100)
	check(main.map.route.get_child_count() == 1, "No further students spawn after early defeat")
	print("INTEGRATION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
