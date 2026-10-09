extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: " + text)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var main = load("res://scenes/main_map2.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var student = load("res://scenes/student.tscn").instantiate()
	main.map.route.add_child(student)
	student.progress = 800
	var letters := {}
	seed(54)
	for i in range(60):
		var p = load("res://scenes/projectile.tscn").instantiate()
		main.map.projectiles.add_child(p)
		p.global_position = student.global_position + Vector2(-200,-40)
		p.configure(student,20)
		check(p.get("letter") != null,"Projectile chooses a magical letter")
		if p.get("letter") != null:
			letters[p.letter] = true
			check(p.letter in ["A","B","C"],"Only A/B/C projectiles")
			var letter: String = p.letter
			var before: Vector2 = p.global_position
			p._process(0.05)
			check(p.letter == letter,"Flight animation never changes chosen letter")
			check(is_equal_approx(p.global_position.distance_to(before),32),"Flight speed remains640")
			check(p.rotation == 0 and p.sprite.rotation != 0 and p.sprite.position == Vector2.ZERO,"Book spins around fixed centered origin")
			check(p.flight_frames.size() == 1,"One book flight frame used")
			for frame in p.flight_frames: check(frame.get_size() == Vector2(600,760),"Book frame canvas fixed")
		p.free()
	check(letters.size() == 3,"Repeated real shots select all three random letters")
	var hit = load("res://scenes/projectile.tscn").instantiate()
	main.map.projectiles.add_child(hit)
	hit.configure(student,20)
	hit.global_position = student.global_position+Vector2(0,-40)
	hit._process(0.1)
	check(student.knowledge == 20 and hit.spent,"Letter retains original single-target hit and20Knowledge")
	hit._process(1)
	check(student.knowledge == 20,"Spent letter cannot hit twice")
	var stale = load("res://scenes/projectile.tscn").instantiate()
	main.map.projectiles.add_child(stale)
	stale.configure(student,20)
	student.complete(true)
	stale._process(0.1)
	check(stale.spent and stale.is_queued_for_deletion(),"Letter safely expires when target graduates")
	for kind in ["normal","pe"]:
		for sex in ["boy","girl"]:
			var s = load("res://scenes/student.tscn").instantiate()
			s.configure(kind,sex)
			main.map.route.add_child(s)
			check(s.get("slow_indicator") != null,"Student has supplied droplet indicator")
			if s.get("slow_indicator") != null:
				check(not s.slow_indicator.visible,"Droplets hidden without slow")
				s.apply_slow()
				check(s.slow_indicator.visible,"Droplets appear immediately with slow")
				var origin: Vector2 = s.slow_indicator.position
				s._process(1.0)
				s.apply_slow()
				s._process(1.5)
				check(s.slow_indicator.visible and is_equal_approx(s.speed,s.base_speed*.70),"Refreshed slow retains droplets and does not stack")
				check(s.slow_indicator.position == origin,"Animated droplets retain pivot")
				s._process(0.6)
				check(not s.slow_indicator.visible and s.speed == s.base_speed,"Droplets disappear exactly when slow expires")
	main.free()
	main = load("res://scenes/main_map2.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	var slot = main.map.slots.get_child(2)
	main.build(slot,"blackboard")
	var targets := []
	for offset in [Vector2(0,60),Vector2(35,70),Vector2(180,80)]:
		var s = load("res://scenes/student.tscn").instantiate()
		s.configure("normal" if targets.is_empty() else "pe","girl")
		main.map.route.add_child(s)
		s.position = slot.position+offset
		targets.append(s)
	slot.tower._process(0.1)
	check(targets[0].knowledge == 15 and targets[1].knowledge == 15 and targets[2].knowledge == 0,"Sponge preserves15Knowledge and105AoE")
	check(targets[0].slow_remaining == 2.0 and targets[1].slow_remaining == 2.0 and targets[2].slow_remaining == 0,"Normal and PE slowed; outside target untouched")
	var swipes := []
	for child in main.map.effects.get_children():
		if child.get("kind") == "science_cloud": swipes.append(child)
	check(swipes.size() == 1,"Science creates supplied cloud and animated orb")
	if not swipes.is_empty():
		check(swipes[0].global_position.distance_to(targets[0].global_position) < 1,"Swipe centered at original AoE target")
		swipes[0].advance(0.7)
		check(swipes[0].is_queued_for_deletion(),"Short sponge swipe frees itself")
	for i in range(3):
		var splash := false
		for child in targets[i].get_children():
			if child.get("kind") == "wet_splash": splash = true
		check(not splash,"Science replaces old wet splash"); if i<2: check(targets[i].drop_frames.size()==4,"Science slow indicator uses four orb frames")
	main.free()
	print("V0.005: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
