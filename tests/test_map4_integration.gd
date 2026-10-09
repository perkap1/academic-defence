extends "res://tests/test_integration.gd"
func run() -> void:
	var main = load("res://scenes/main_map4.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var order := [5,7,6,8,1,10,2,11,3,12,0,9,4,13]
	for wave in range(17):
		for index in order:
			var slot = main.map.slots.get_child(index)
			var kind := "blackboard" if index in [6,8] else "book"
			var cost := 100 if kind == "blackboard" else 70
			if not slot.occupied and main.game.gold >= cost: main.build(slot,kind)
		for index in order:
			var slot = main.map.slots.get_child(index)
			if slot.occupied:
				main.select_slot(slot)
				while main.upgrade(slot): pass
		check(main.waves.start_wave(),"Map4 ordinary budget starts wave %d" % (wave+1))
		simulate(main,160)
		print("MAP4 WAVE %d: lives=%d gold=%d graduates=%d towers=%d" % [wave+1,main.game.lives,main.game.gold,main.game.graduated,main.map.towers.get_child_count()])
		check(not main.waves.active,"Wave fully resolves")
		if main.game.finished: break
	check(main.game.won and main.waves.wave == 17,"Ordinary-budget strategy wins Map4")
	check(main.game.graduated+main.game.escaped==main.waves.counts.reduce(func(a,b): return a+b,0),"All students accounted for once")
	check(4 in root.get_node("Progression").completed_levels,"Victory saves Autumn Campus completion")
	check(main.map.towers.get_child_count()==14,"Every painted build slot supports towers")
	main.free()
	print("MAP4 INTEGRATION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
