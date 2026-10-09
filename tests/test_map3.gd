extends SceneTree
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: "+message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(FileAccess.file_exists("res://scenes/main_map3.tscn"),"Map3 in existing project")
	if not FileAccess.file_exists("res://scenes/main_map3.tscn"):
		quit(1)
		return
	var main = load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode = Node.PROCESS_MODE_DISABLED
	check(main.map.slots.get_child_count() == 14,"Fourteen user-confirmed slots")
	check(main.map.get_routes().size() == 2,"Two entrances")
	check(main.waves.counts == [8,12,14,15,18,21,23,26,27,30,33,35,37,40,44],"15 exact wave totals")
	for wave in range(15):
		main.waves.wave = wave
		main.waves.active = false
		main.waves.students.clear()
		check(main.waves.start_wave(),"Wave %d starts" % (wave+1))
		main.waves._process(100)
		var counts := {"normal":0,"pe":0,"bookworm":0,"snack":0}
		for student in main.waves.students: counts[student.student_type] += 1
		check(counts.bookworm == [0,0,0,2,3,3,5,5,7,6,8,8,10,10,12][wave],"Exact Bookworms per wave")
		check(counts.pe == [0,2,4,4,4,5,6,7,8,8,10,10,12,10,12][wave],"Exact PE per wave")
		var routes: Array = main.map.get_routes()
		check(absi(routes[0].get_child_count()-routes[1].get_child_count())<=1,"Both entrances used evenly")
		for student in main.waves.students:
			student.get_parent().remove_child(student)
			student.free()
	main.free()
	print("MAP3: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
