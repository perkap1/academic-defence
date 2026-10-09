extends SceneTree
var failures := 0
var checks := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: "+message)
func _initialize(): call_deferred("run")
func run():
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode = Node.PROCESS_MODE_DISABLED
	for kind in ["normal","pe_boy","pe_girl","bookworm"]:
		var unit = load("res://scenes/bookworm.tscn" if kind=="bookworm" else "res://scenes/student.tscn").instantiate()
		if kind.begins_with("pe"): unit.configure("pe",kind.trim_prefix("pe_"))
		main.map.route.add_child(unit)
		check(unit.frames.side[2] is AtlasTexture,"New atlas for "+kind)
		if not unit.frames.side[2] is AtlasTexture: continue
		check(unit.frames.side[2].atlas.resource_path.contains("enemies_v014"),"New supplied sheet for "+kind)
		for facing in ["front","side","back"]:
			check(unit.frames[facing].size()==6,"Two idle and four movement poses")
			for texture in unit.frames[facing]:
				check(texture.get_size()==unit.frames[facing][0].get_size(),"Fixed frame canvas")
				check(texture.filter_clip,"Atlas cannot bleed into neighboring poses")
		var teacher = Node2D.new()
		main.add_child(teacher)
		teacher.global_position = unit.global_position+Vector2(100,0)
		unit.teacher=teacher
		unit.assistant_hold=true
		var before: float=unit.progress
		unit.animation_time=0
		unit._process(0.1)
		var idle = unit.sprite.texture
		unit._process(0.5)
		check(unit.sprite.texture!=idle,"Both idle frames animate while held: "+kind)
		check(unit.progress==before,"Idle does not move held unit: "+kind)
		check(unit.base_speed==(114.75 if kind.begins_with("pe") else 85.0),"Speed preserved: "+kind)
		unit.direction="side"
		check(unit.side_flipped(1) and not unit.side_flipped(-1),"Idle faces correct teacher direction")
		if kind=="bookworm":
			for state in range(3):
				unit.teach(999)
				check(unit.books==2-state and unit.knowledge==0,"Shield removes one book")
				check(unit.sprite.texture==unit.frames[unit.direction][1],"Shield change retains idle phase")
		unit.assistant_hold=false
		for pose in range(4):
			unit.animation_time=(pose+0.05)/(10.0 if kind.begins_with("pe") else 8.0)
			check(unit.animation_frame()==pose+2,"Four movement frames at correct playback rate")
			var source_faces_right=kind=="pe_girl" and pose<3
			check(unit.side_flipped(1)==not source_faces_right,"Every movement pose faces right correctly")
		main.remove_child(teacher)
		teacher.free()
	main.free()
	print("ENEMY REFRESH: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
