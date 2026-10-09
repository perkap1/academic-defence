extends "res://tests/test_integration.gd"

func run() -> void:
	var packed = load("res://scenes/main_map2.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var order := [2,4,3,5,1,0,6,7]
	for wave in range(12):
		for index in order:
			var slot = main.map.slots.get_child(index)
			var kind := "blackboard" if index in [3,0,7] else "book"
			var cost := 100 if kind == "blackboard" else 70
			if not slot.occupied and main.game.gold >= cost:
				main.build(slot,kind)
		check(main.waves.start_wave(),"Map2 ordinary-budget wave %d starts" % (wave+1))
		simulate(main,160)
		print("MAP2 WAVE %d: lives=%d gold=%d graduates=%d towers=%d" % [wave+1,main.game.lives,main.game.gold,main.game.graduated,main.map.towers.get_child_count()])
		check(not main.waves.active,"Map2 wave fully resolves")
		if main.game.finished: break
	check(main.game.won and main.waves.wave == 12,"Map2 ordinary-budget mixed strategy wins12waves")
	check(main.game.graduated + main.game.escaped == main.waves.counts.reduce(func(a,b):return a+b,0),"Map2 accounts for all students exactly once")
	check(main.map.towers.get_child_count() == 8,"Strategy uses only eight legal slots")
	main.free()
	main = packed.instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	main.waves.start_wave()
	simulate(main,100)
	check(main.game.lives == 4 and not main.game.finished,"Map2 wave1 without towers loses6 reputation")
	main.waves.start_wave()
	simulate(main,100)
	check(main.game.finished and not main.game.won and main.waves.remaining == 0,"Map2 no-tower strategy loses and stops spawn")
	check(not main.waves.start_wave(),"Map2 defeat blocks additional waves")
	print("MAP2 INTEGRATION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
