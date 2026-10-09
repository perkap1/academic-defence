extends "res://tests/test_integration.gd"
func run() -> void:
	var main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var order := [4,7,12,13,5,8,2,9,3,6,1,10,0,11]
	for wave in range(15):
		for index in order:
			var slot = main.map.slots.get_child(index)
			var kind := "blackboard" if index in [7,8,3,6] else "book"
			var cost := 100 if kind == "blackboard" else 70
			if not slot.occupied and main.game.gold >= cost + slot.get_clear_cost():
				if slot.is_blocked(): main.game.try_clear_site(slot)
				main.build(slot,kind)
		for index in order:
			var slot = main.map.slots.get_child(index)
			if slot.occupied:
				main.select_slot(slot)
				while main.upgrade(slot): pass
		check(main.waves.start_wave(),"Map3 ordinary budget starts wave %d" % (wave+1))
		simulate(main,160)
		print("MAP3 WAVE %d: lives=%d gold=%d graduates=%d towers=%d" % [wave+1,main.game.lives,main.game.gold,main.game.graduated,main.map.towers.get_child_count()])
		check(not main.waves.active,"Wave fully resolves")
		if main.game.finished: break
	check(main.game.won and main.waves.wave == 15,"Ordinary-budget strategy wins Map3")
	check(main.game.graduated+main.game.escaped==main.waves.counts.reduce(func(a,b): return a+b,0),"All students accounted for once")
	main.free()
	print("MAP3 INTEGRATION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
