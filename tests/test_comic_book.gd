extends "res://tests/test_bookworm.gd"
func run() -> void:
	var main=load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=1000
	var slot=main.map.slots.get_child(0)
	main.build(slot,"book")
	var tower=slot.tower
	check(tower.frames.size()==9,"Five new idle and four new throw frames")
	check(tower.has_node("LevelBadge") and tower.get_node("LevelBadge").z_index>tower.sprite.z_index,"Gold level glyph renders above opaque banner")
	if tower.frames.size()!=9:
		main.free()
		quit(1)
		return
	var point:Vector2=tower.global_position
	check(tower.sprite.offset==Vector2(-300,-465),"New frames share a stable bottom-center origin")
	check(is_equal_approx(tower.get_node("LevelBadge").position.y,6.3),"Level numeral sits on the new banner")
	for image in tower.frames:check(image.get_size()==Vector2(600,500),"Common canvas across all idle and throw frames")
	for level in range(1,4):
		if level>1: main.game.try_upgrade(slot)
		check(tower.global_position==point,"Upgrade keeps position")
		check(tower.level==level,"Level remains correct")
		check(tower.frames[0].atlas.resource_path.ends_with("book_teacher_sheet.png"),"New supplied source at all levels")
		for frame in range(4):
			tower.animation_time=0.4-frame*0.1
			check(tower.get_visual_frame()==5+frame,"Throw frames ordered")
			check(tower.base_sprite.texture==tower.frames[0],"Desk base remains fixed throughout throw and upgrades")
	var student=load("res://scenes/student.tscn").instantiate()
	main.map.route.add_child(student)
	var projectile=load("res://scenes/projectile.tscn").instantiate()
	main.map.projectiles.add_child(projectile)
	projectile.configure(student,60,true)
	projectile.global_position=student.global_position+Vector2(-300,-40)
	check(projectile.flight_frames.size()==1,"Single book frame")
	projectile._process(0.1)
	check(projectile.sprite.rotation!=0,"Engine spins book during flight")
	check(projectile.sprite.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"Sharp book texture")
	main.free()
	print("COMIC BOOK: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
