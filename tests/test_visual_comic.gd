extends "res://tests/test_visual_economy.gd"
func run() -> void:
	var main=load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=2000
	var towers=[]
	for i in range(3):
		var slot=main.map.slots.get_child([4,12,5][i])
		main.build(slot,"book")
		for upgrade in range(i): main.game.try_upgrade(slot)
		towers.append(slot.tower)
	for frame in range(12):
		for tower in towers:
			tower.sprite.texture=tower.frames[frame]
		await capture("comic-frame%d" % frame)
	for i in range(3):
		main.select_slot(main.map.slots.get_child([4,12,5][i]))
		await capture("comic-level%d" % (i+1))
	main.free()
	print("COMIC VISUAL: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
