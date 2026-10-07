extends "res://tests/test_visual_economy.gd"
func run()->void:
	var main=load("res://scenes/main_map3.tscn").instantiate()
	root.add_child(main)
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=2000
	var towers=[]
	for i in range(3):
		var slot=main.map.slots.get_child([4,12,5][i])
		main.build(slot,"blackboard")
		for upgrade in range(i):main.game.try_upgrade(slot)
		towers.append(slot.tower)
	for frame in range(9):
		for tower in towers:tower.sprite.texture=tower.frames[frame]
		await capture("science-frame%d"%frame)
	var effect=towers[0].create_attack_effect()
	main.map.effects.add_child(effect)
	effect.global_position=main.map.global_position+Vector2(950,466)
	effect.launch_from(towers[0].global_position+Vector2(0,-100))
	for frame in range(4):
		effect.elapsed=0;effect.advance((frame+0.1)*0.04)
		await capture("science-orb%d"%frame)
	for frame in range(5):
		effect.elapsed=0;effect.advance(0.16+(frame+0.1)*0.09)
		await capture("science-cloud%d"%frame)
	for i in range(3):
		main.select_slot(main.map.slots.get_child([4,12,5][i]))
		await capture("science-level%d"%(i+1))
	main.free()
	print("SCIENCE VISUAL: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
