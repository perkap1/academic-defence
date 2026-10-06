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

func check_banner_layout(ui) -> void:
	for label in [ui.banner_description,ui.banner_extra,ui.invested_label,ui.upgrade_caption]:
		check(label.position.y+label.get_minimum_size().y<=140,"Banner text clears lower frame: "+label.text)

func run() -> void:
	for map_name in ["main","main_map2"]:
		var main=load("res://scenes/%s.tscn" % map_name).instantiate()
		root.add_child(main)
		current_scene=main
		await process_frame
		main.game.gold=1000
		main.game.changed.emit()
		var a=main.map.slots.get_child(2)
		var b=main.map.slots.get_child(4)
		await click_at(a.global_position)
		await click_at(main.ui.book_button.get_global_rect().get_center())
		await click_at(a.global_position)
		check(main.ui.tower_banner.visible and a.tower.show_range,"Actual Book click opens banner/range")
		var banner_position:Vector2=main.ui.tower_panel.position
		var origin:Vector2=a.tower.global_position
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(a.tower.level==2 and main.game.gold==850,"Actual Book upgrade2 click costs80 once")
		check(main.ui.tower_panel.position==banner_position and a.tower.global_position==origin,"Banner and tower fixed through upgrade")
		await capture("AcademicDefence-v008-%s-book2.png" % map_name)
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(a.tower.level==3 and main.game.gold==720,"Actual Book upgrade3 click costs130 once")
		check(main.ui.upgrade_button.disabled and main.ui.upgrade_caption.text=="MAX LEVEL","Maximum disabled and labelled")
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(main.game.gold==720,"Click MAX cannot charge")
		check_banner_layout(main.ui)
		await capture("AcademicDefence-v008-%s-book3.png" % map_name)
		await click_at(Vector2(1000,350))
		check(not main.ui.tower_panel.visible and not a.tower.show_range,"Ground click closes banner/range")
		await click_at(b.global_position)
		await click_at(main.ui.blackboard_button.get_global_rect().get_center())
		await click_at(b.global_position)
		check(not a.tower.show_range and b.tower.show_range,"Other tower replaces selection")
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(b.tower.level==2 and main.game.gold==520,"Actual Board upgrade2 costs100")
		await capture("AcademicDefence-v008-%s-board2.png" % map_name)
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(b.tower.level==3 and main.game.gold==370,"Actual Board upgrade3 costs150")
		check_banner_layout(main.ui)
		await capture("AcademicDefence-v008-%s-board3.png" % map_name)
		await click_at(main.ui.sell_button.get_global_rect().get_center())
		check(not b.occupied and main.game.gold==545,"Actual Board3 Sell refunds175 once")
		await click_at(a.global_position)
		await click_at(main.ui.sell_button.get_global_rect().get_center())
		check(not a.occupied and main.game.gold==685,"Actual Book3 Sell refunds140 once")
		main.game.gold=100
		main.game.changed.emit()
		await click_at(a.global_position)
		await click_at(main.ui.book_button.get_global_rect().get_center())
		await click_at(a.global_position)
		check(main.ui.upgrade_button.disabled and main.ui.upgrade_caption.text.contains("80"),"Insufficient disabled with visible price")
		await click_at(main.ui.upgrade_button.get_global_rect().get_center())
		check(a.tower.level==1 and main.game.gold==30,"Disabled actual click cannot buy")
		await capture("AcademicDefence-v008-%s-disabled.png" % map_name)
		main.free()
		await process_frame
	print("UPGRADES VISUAL: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
