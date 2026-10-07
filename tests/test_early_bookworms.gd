extends "res://tests/test_bookworm.gd"
func run()->void:
	for scene in ["main","main_map2"]:
		var main=load("res://scenes/%s.tscn"%scene).instantiate()
		root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
		var expected:Array=[0,0,0,1,1,2,2] if scene=="main" else [0,0,0,1,2,2,3,3,4,4,5,6]
		check(main.waves.bookworm_counts==expected,"Gradual Bookworms on %s"%scene)
		for wave in range(expected.size()):
			main.waves.wave=wave
			check(main.waves.start_wave(),"Wave starts")
			main.waves._process(100)
			var books:=0;var pe:=0
			for s in main.waves.students:
				if s.student_type=="bookworm":
					books+=1;check(s.books==3,"Real Bookworm starts with three shields")
				elif s.student_type=="pe":pe+=1
			check(books==expected[wave],"Exact Bookworm count")
			check(pe==main.waves.pe_counts[wave],"Existing PE counts preserved")
			check(main.waves.students.size()==main.waves.counts[wave],"Total wave size preserved")
			for s in main.waves.students:s.free()
			main.waves.students.clear();main.waves.active=false
		main.free()
	print("EARLY BOOKWORMS: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
