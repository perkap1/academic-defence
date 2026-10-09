extends "res://tests/test_bookworm.gd"
func run() -> void:
	var main=load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	# Unit fixture: isolate tower/combat behavior from paid site clearing.
	for site in main.map.slots.get_children(): site.set_blocker("")
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=2000
	var kinds=["book","blackboard","assistant","economy"]
	var factors=[0.247,0.2275,0.5525,0.377]
	for i in range(4):
		var slot=main.map.slots.get_child(i)
		main.build(slot,kinds[i])
		var tower=slot.tower
		var sprite: Sprite2D=tower.get_node("Sprite")
		check(sprite.scale.is_equal_approx(Vector2.ONE*factors[i]),"30 percent larger than v0.014.1: "+kinds[i])
		check(tower.scale==Vector2.ONE,"World scale and range unchanged")
		if i<2:
			check(sprite.flip_h and tower.base_sprite.flip_h,"Character and base face left entrance")
			check(tower.get_node("LevelBadge").scale==Vector2.ONE*0.65,"Level digit grows proportionally without mirroring")
			var point: Vector2=tower.global_position
			main.game.try_upgrade(slot)
			check(sprite.scale.is_equal_approx(Vector2.ONE*factors[i]) and tower.global_position==point,"Upgrade retains new size and position")
		elif i==2:
			for assistant in tower.assistants: check(assistant.scale==Vector2.ONE*0.7,"Road assistants retain their size")
	main.free()
	print("TOWER SIZE: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
