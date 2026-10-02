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
	for scene in ["main","main_map2"]:
		var main = load("res://scenes/%s.tscn" % scene).instantiate()
		root.add_child(main)
		main.process_mode = Node.PROCESS_MODE_DISABLED
		check(main.ui.build_menu.has_method("contains_point"),"Build menu is radial with circular outside-hit test")
		if main.ui.build_menu.has_method("contains_point"):
			for slot in main.map.slots.get_children():
				main.select_slot(slot)
				check(main.ui.build_menu.get_global_rect().get_center() == slot.global_position,"Radial center equals every slot on %s" % scene)
				check(main.ui.build_menu.contains_point(slot.global_position),"Center is inside radial menu")
				check(not main.ui.build_menu.contains_point(slot.global_position+Vector2(215,215)),"Rectangle corner counts as outside circular menu")
				var before: Vector2 = main.ui.build_menu.position
				main.game.gold = 69
				main.update_ui()
				check(main.ui.book_button.disabled and main.ui.blackboard_button.disabled,"Unaffordable radial options disabled")
				main.game.gold = 70
				main.update_ui()
				check(not main.ui.book_button.disabled and main.ui.blackboard_button.disabled,"70KP enables only Book")
				main.game.gold = 100
				main.update_ui()
				check(not main.ui.blackboard_button.disabled,"100KP enables Blackboard")
				check(main.ui.build_menu.position == before,"Affordability state does not shift radial anchor")
				main.ui.close_build_menu()
		main.game.gold = 200
		for kind in ["normal","pe"]:
			for sex in ["boy","girl"]:
				var student = load("res://scenes/student.tscn").instantiate()
				student.configure(kind,sex)
				main.map.route.add_child(student)
				student.progress = 550
				student.resolved.connect(main.student_resolved)
				main.waves.students.append(student)
				var gold: int = main.game.gold
				student.teach(100)
				check(student.done and not student.is_in_group("students"),"Graduate immediately untargetable for %s/%s" % [kind,sex])
				check(main.game.gold == gold+10,"Graduate rewards once")
				student.teach(100)
				check(main.game.gold == gold+10,"Repeated hit cannot duplicate graduation reward")
				var effects := []
				for child in main.map.effects.get_children():
					if child.has_method("advance"): effects.append(child)
				check(effects.size() > 0,"Graduation creates shared smoke/cap/dust effect")
				if not effects.is_empty():
					var effect = effects.back()
					check(effect.global_position.distance_to(student.global_position) < 1,"Effect retains student world anchor")
					check(effect.frames.size() == 9,"Nine smoke-cap-dust frames")
					check(effect.duration >= 0.6 and effect.duration <= 1.0,"Whole effect is short")
					effect.advance(0.4)
					check(effect.frame_index >= 4 and not effect.is_queued_for_deletion(),"Effect progresses into floating cap stage")
					effect.advance(0.5)
					check(effect.is_queued_for_deletion(),"Effect cleans itself up by one second")
		main.free()
	print("V0.004: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
