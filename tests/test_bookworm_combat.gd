extends "res://tests/test_bookworm.gd"
func spawn(main, path, point: Vector2):
	var student = load("res://scenes/bookworm.tscn").instantiate()
	path.add_child(student)
	student.lane_offset = 0
	student.progress = path.curve.get_closest_offset(path.to_local(point))
	student.update_lane_position()
	return student
func run() -> void:
	var main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var a = spawn(main,main.map.route,Vector2(950,466)+main.map.global_position)
	var b = spawn(main,main.map.lower_route,a.global_position)
	check(a.global_position.distance_to(b.global_position)<1,"Routes share common world position")
	main.game.gold = 1000
	var slot = main.map.slots.get_child(4)
	main.build(slot,"blackboard")
	var board = slot.tower
	board._process(0.1)
	for effect in main.map.effects.get_children():
		if effect.has_method("advance"): effect.advance(0.7)
	for student in [a,b]:
		check(student.books==2 and student.knowledge==0,"One AoE event removes one book on either entrance")
		check(student.slow_remaining==2.0 and student.slow_strength==0.3,"Slow passes through book shield")
	board.cooldown = 99
	var projectile = load("res://scenes/projectile.tscn").instantiate()
	main.map.projectiles.add_child(projectile)
	projectile.configure(b,60,true)
	projectile.global_position=b.global_position
	projectile._process(1)
	projectile._process(1)
	check(b.books==1 and b.knowledge==0,"Golden letter collision spends once, removes one book")
	a.free()
	b.free()
	main.sell(slot)
	main.build(slot,"book")
	b=spawn(main,main.map.lower_route,Vector2(950,466)+main.map.global_position)
	slot.tower._process(0.1)
	check(main.map.projectiles.get_child_count()>=1,"Book Tower finds lower-route student")
	main.sell(slot)
	main.build(slot,"assistant")
	var post=slot.tower
	check(post.try_move_rally(b.global_position),"Rally snapping supports lower route")
	for worker in post.assistants: worker._process(4)
	var worker=post.assistants[0]
	worker.cooldown=0
	worker._process(0.01)
	worker._process(1)
	check(b.assistant_hold and b.teacher==worker,"Assistant holds Bookworm from lower route")
	var before:float=b.progress
	b._process(0.5)
	check(b.progress==before,"Bookworm stops during lesson")
	for i in range(3):
		worker._process(0.2)
		check(b.books==2-i and b.knowledge==0,"Each normal lesson tick removes exactly one shield")
	worker._process(0.2)
	check(b.knowledge==1,"Lesson teaches after last shield tick")
	worker._process(3)
	check(not b.assistant_hold and b.teacher==null,"Lesson releases Bookworm normally")
	b._process(0.1)
	check(b.progress>before,"Movement resumes after teaching")
	main.sell(slot)
	check(post.is_queued_for_deletion() or not is_instance_valid(post),"Sale removes assistants")
	main.free()
	print("BOOKWORM COMBAT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
