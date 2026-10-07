extends "res://tests/test_visual_economy.gd"
func run() -> void:
	var main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.game.gold=2000
	main.update_ui()
	for i in range(14):
		var slot=main.map.slots.get_child(i)
		await click_at(slot.global_position)
		check(main.ui.build_menu.visible,"Slot %d opens radial by mouse" % i)
		await click_at(main.ui.book_button.get_global_rect().get_center())
		check(slot.occupied,"Slot %d builds by mouse" % i)
		await click_at(slot.global_position)
		check(main.ui.tower_banner.visible,"Slot %d opens banner" % i)
		await click_at(main.ui.banner_sell.get_global_rect().get_center())
		check(not slot.occupied,"Slot %d sells by mouse" % i)
	main.game.gold=1000
	for i in [4,7,12,13]: main.build(main.map.slots.get_child(i),"blackboard" if i==7 else "book")
	main.waves.wave=3
	await click_at(main.ui.start_button.get_global_rect().get_center())
	check(main.waves.active and main.waves.wave==4,"Start wave4 by mouse")
	main.waves._process(10)
	check(main.ui.bookworm_tutorial.visible,"Wave4 shows first Bookworm tutorial")
	main.process_mode=Node.PROCESS_MODE_DISABLED
	for path in main.map.get_routes():
		for i in range(4):
			var student=load("res://scenes/bookworm.tscn").instantiate()
			path.add_child(student)
			student.progress=450+i*145
			student.books=3-i
			student.update_lane_position()
			student.update_shield_art()
	await capture("map3-bookworm-states")
	var b=load("res://scenes/bookworm.tscn").instantiate()
	main.map.route.add_child(b)
	b.progress=800
	b.update_lane_position()
	for hit in range(3):
		b.teach(60)
		check(b.books==2-hit,"Graphical shield change")
		for frame in range(4):
			var effect=main.map.effects.get_child(main.map.effects.get_child_count()-1)
			effect.elapsed=frame*0.1125
			effect._process(0)
			await capture("map3-hit%d-frame%d" % [hit,frame])
	main.free()
	print("MAP3 VISUAL: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
