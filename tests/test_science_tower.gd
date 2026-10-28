extends "res://tests/test_bookworm.gd"
func run()->void:
	var main=load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=2000
	var slot=main.map.slots.get_child(4)
	main.build(slot,"blackboard")
	var tower=slot.tower
	check(tower.frames.size()==11,"Six science idle and five attack poses")
	check(tower.has_node("LevelBadge"),"Science levels have fixed gold badge")
	check(tower.get_display_name().contains("Science"),"Science name in information banner")
	if tower.frames.size()!=11:
		main.free();quit(1);return
	var origin:Vector2=tower.global_position
	for image in tower.frames:check(image.get_size()==Vector2(600,600),"All eleven frames share a common canvas")
	check(is_equal_approx(tower.get_node("LevelBadge").position.y,6.3),"Gold number sits on the new red banner")
	for level in range(1,4):
		if level>1: main.game.try_upgrade(slot)
		check(tower.global_position==origin,"Upgrade preserves position")
		check(tower.frames[0].atlas.resource_path.ends_with("science_teacher_v036.png"),"Same supplied art at every level")
		check(tower.knowledge_per_hit==[15,19,22][level-1] and tower.area_radius==[105.0,126.0,147.0][level-1],"Existing Knowledge and AoE balance")
		check(tower.slow_strength==([0.30,0.30,0.40][level-1]),"Existing non-stacking slow strength")
		for frame in range(6):
			tower.animation_time=0;tower.visual_time=frame/1.5
			check(tower.get_visual_frame()==frame,"Ordered calm science idle")
		for frame in range(5):
			tower.animation_time=0.4-frame*0.08
			check(tower.get_visual_frame()==6+frame,"Ordered five experiment poses")
			tower.update_sprite(0)
			check(tower.base_sprite.texture.region==Rect2(0,120,270,385),"Full desk base remains fixed during experiments")
			check(tower.sprite.material.get_shader_parameter("science_frame")==6+frame and tower.sprite.material.get_shader_parameter("source_flipped")==tower.sprite.flip_h,"Cell cleanup follows displayed frame and facing")
	var effect=tower.create_attack_effect()
	main.map.effects.add_child(effect)
	check(effect.kind=="science_cloud" and effect.frames.size()==5,"Five supplied cloud frames")
	check(effect.orb_frames.size()==4,"Four animated science orb frames")
	for frame in range(5):
		effect.elapsed=0;effect.advance((frame+0.02)*0.09)
		check(effect.sprite.texture==effect.frames[frame],"Stable ordered cloud animation")
	check(main.ui.blackboard_button.texture_normal.atlas.resource_path.ends_with("science_teacher_v036.png"),"Radial menu uses new science art")
	check(tower.get_sell_refund()==275,"Half of 120+150+280 investment")
	main.free()
	print("SCIENCE TOWER: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
