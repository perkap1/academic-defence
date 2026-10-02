extends "res://tests/test_visual.gd"
func run() -> void:
	var main = load("res://scenes/main_map2.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var slot = main.map.slots.get_child(2)
	main.build(slot,"blackboard")
	main.build(main.map.slots.get_child(4),"book")
	var students := []
	for i in range(4):
		var s = load("res://scenes/student.tscn").instantiate()
		s.configure("normal" if i in [0,3] else "pe","girl" if i == 2 else "boy")
		main.map.route.add_child(s)
		s.position = slot.position+[Vector2(0,-120),Vector2(25,-75),Vector2(60,-120),Vector2(200,-50)][i]
		students.append(s)
	slot.tower._process(.01)
	for s in students:
		for child in s.get_children():
			if child.get("kind") == "wet_splash": child.advance(.16)
	for effect in main.map.effects.get_children():
		if effect.get("kind") == "sponge_swipe": effect.advance(.18)
	main.map.towers.get_child(1)._process(.01)
	check(main.map.projectiles.get_child_count() == 1,"Book fires actual letter from tower")
	var p = main.map.projectiles.get_child(0)
	var glyph: String = p.letter
	p._process(.15)
	check(p.letter == glyph and p.rotation == 0,"Actual projectile animates upright")
	for i in range(3): check(students[i].slow_indicator.visible,"Normal and both PE variants display droplets")
	check(not students[3].slow_indicator.visible,"Outside student has no droplets")
	await capture("AcademicDefence-v005-attacks.png")
	for effect in main.map.effects.get_children(): effect.advance(.4)
	for s in students:
		for child in s.get_children():
			if child.get("kind") == "wet_splash": child.advance(.4)
	await process_frame
	check(main.map.effects.get_child_count() == 0,"Swipe effects clean up")
	for s in students: s._process(2.1)
	for s in students: check(not s.slow_indicator.visible,"Droplets vanish after slow expiry")
	main.process_mode = Node.PROCESS_MODE_INHERIT
	await click_at(Vector2(1585,95))
	main = current_scene
	main.build(main.map.slots.get_child(2),"blackboard")
	main.build(main.map.slots.get_child(4),"book")
	main.waves.wave = 4
	main.waves.start_wave()
	Engine.time_scale = 6
	await create_timer(13).timeout
	Engine.time_scale = 1
	await capture("AcademicDefence-v005-gameplay.png")
	print("VISUAL V0.005: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
