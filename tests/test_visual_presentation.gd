extends SceneTree

var checks := 0
var failures := 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: " + description)
	else:
		print("PASS: " + description)

func _initialize() -> void:
	call_deferred("run")

func click_at(point: Vector2) -> void:
	var window_point := root.get_final_transform() * point
	var motion := InputEventMouseMotion.new()
	motion.position = window_point
	root.push_input(motion)
	await process_frame
	var press := InputEventMouseButton.new()
	press.position = window_point
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	root.push_input(press)
	await physics_frame
	await process_frame
	var release := InputEventMouseButton.new()
	release.position = window_point
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	root.push_input(release)
	await physics_frame
	await process_frame

func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../" + filename))
	check(error == OK,"Rendered " + filename)

func run()->void:
	for map_name in ["main","main_map2"]:
		var main=load("res://scenes/%s.tscn"%map_name).instantiate()
		root.add_child(main)
		current_scene=main
		await process_frame
		main.game.gold=2000
		var book_slot=main.map.slots.get_child(2)
		var board_slot=main.map.slots.get_child(4)
		var assistant_slot=main.map.slots.get_child(1)
		main.build(book_slot,"book")
		main.build(board_slot,"blackboard")
		main.build(assistant_slot,"assistant")
		var book=book_slot.tower
		var board=board_slot.tower
		main.set_process(false)
		main.waves.set_process(false)
		for tower in [book,board]:tower.set_process(false)
		for i in range(16):
			var student=load("res://scenes/student.tscn").instantiate()
			student.configure("normal" if i%3==0 else "pe","girl" if i%3==2 else "boy")
			main.map.route.add_child(student)
			student.progress=250+i*85
			student.update_lane_position()
			student.set_process(false)
		for level in range(1,4):
			if level>1:
				main.game.try_upgrade(book_slot)
				main.game.try_upgrade(board_slot)
			main.select_slot(book_slot)
			var position:Vector2=book.global_position
			var base_texture=book.base_sprite.texture
			for i in range(8):
				book.animation_time=0
				book.visual_time=i*.25
				book.update_sprite(0)
				check(book.global_position==position and book.base_sprite.texture==base_texture,"Static Book base across8 periods")
				if i<4:await capture("AcademicDefence-v009-%s-book%d-frame%d.png"%[map_name,level,i])
			book.animation_time=.2
			book.update_sprite(0)
			check(book.sprite.texture==book.frames[4],"Actual golden Book attack frame")
			await capture("AcademicDefence-v009-%s-book%d-attack.png"%[map_name,level])
			main.select_slot(board_slot)
			position=board.global_position
			base_texture=board.base_sprite.texture
			for i in range(4):
				board.animation_time=.4-i*.1
				board.update_sprite(0)
				check(board.sprite.texture==board.frames[i+1] and board.global_position==position and board.base_sprite.texture==base_texture,"Four Board attack frames, fixed base")
				var effect=board.create_attack_effect()
				main.map.effects.add_child(effect)
				effect.global_position=board.global_position+Vector2(-140,60)
				effect.set_process(false)
				effect.advance(i*.08)
				await capture("AcademicDefence-v009-%s-board%d-attack%d.png"%[map_name,level,i])
				effect.free()
			board.animation_time=0
			board.update_sprite(0)
			check(board.sprite.texture==board.frames[0],"Board returns to idle")
			await capture("AcademicDefence-v009-%s-board%d-idle.png"%[map_name,level])
		main.free()
		await process_frame
	print("PRESENTATION VISUAL: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
