extends "res://tests/test_bookworm.gd"
func run()->void:
	var main=load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=2000
	var slot=main.map.slots.get_child(4)
	main.build(slot,"blackboard")
	var tower=slot.tower
	check(tower.frames.size()==9,"Five science idle and four attack poses")
	check(tower.has_node("LevelBadge"),"Science levels have fixed gold badge")
	check(tower.get_display_name().contains("Science"),"Science name in information banner")
	if tower.frames.size()!=9:
		main.free();quit(1);return
	var origin:Vector2=tower.global_position
	for level in range(1,4):
		if level>1: main.game.try_upgrade(slot)
		check(tower.global_position==origin,"Upgrade preserves position")
		check(tower.frames[0].atlas.resource_path.ends_with("science_teacher_sheet.png"),"Same new art at every level")
		check(tower.knowledge_per_hit==[15,19,22][level-1] and tower.area_radius==[105.0,126.0,147.0][level-1],"Existing Knowledge and AoE balance")
		check(tower.slow_strength==([0.30,0.30,0.40][level-1]),"Existing non-stacking slow strength")
		for frame in range(5):
			tower.animation_time=0;tower.visual_time=frame/3.0
			check(tower.get_visual_frame()==frame,"Ordered calm science idle")
		for frame in range(4):
			tower.animation_time=0.4-frame*0.1
			check(tower.get_visual_frame()==5+frame,"Ordered four experiment poses")
	var effect=tower.create_attack_effect()
	main.map.effects.add_child(effect)
	check(effect.kind=="science_cloud" and effect.frames.size()==5,"Five supplied cloud frames")
	check(effect.orb_frames.size()==4,"Four animated science orb frames")
	for frame in range(5):
		effect.elapsed=0;effect.advance((frame+0.02)*0.09)
		check(effect.sprite.texture==effect.frames[frame],"Stable ordered cloud animation")
	check(main.ui.blackboard_button.texture_normal.atlas.resource_path.ends_with("science_teacher_sheet.png"),"Radial menu uses new science art")
	check(tower.get_sell_refund()==175,"Half of 100+100+150 investment")
	main.free()
	print("SCIENCE TOWER: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
