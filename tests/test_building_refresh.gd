extends "res://tests/test_bookworm.gd"
func run():
	var main=load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.process_mode=Node.PROCESS_MODE_DISABLED
	main.game.gold=5000
	main.build(main.map.slots.get_child(0),"economy")
	var building=main.map.slots.get_child(0).tower
	check(not building.specialize("research"),"Removed specialization rejected")
	check(main.ui.specialization_buttons.size()==2,"Exactly two choices")
	check(building.frames.size()==9,"Study: eight idle and one active")
	main.build(main.map.slots.get_child(1),"assistant")
	var post=main.map.slots.get_child(1).tower
	check(post.has_method("point_at"),"Post supports pointing")
	if post.has_method("point_at"):
		for direction in [Vector2.RIGHT,Vector2(1,1),Vector2.DOWN,Vector2(-1,1),Vector2.LEFT,Vector2(-1,-1),Vector2.UP,Vector2(1,-1)]:
			post.point_at(post.global_position+direction*100)
			check(post.point_remaining>0,"Pointing retriggers")
			check(post.point_direction==["right","down_right","down","down_left","left","up_left","up","up_right"][int(round(fposmod(direction.angle(),TAU)/(PI/4)))%8],"Correct octant")
			check(post.point_frames.size()==3,"Three pointing poses")
		post._process(1)
		check(post.point_remaining==0,"Pointing returns to idle")

	var fixed_base: Texture2D=post.base_sprite.texture
	post.point_at(post.global_position+Vector2(100,0))
	post._process(0.15)
	post.point_at(post.global_position+Vector2(0,-100))
	check(post.point_remaining==0.3 and post.point_direction=="up","Rapid dispatch restarts pointing")
	check(post.base_sprite.texture==fixed_base,"Desk texture stays fixed")
	for branch in ["study","library","scholarship"]:
		var poses=load("res://scripts/building_frames.gd").economy(branch)
		check(poses.size()==(10 if branch=="scholarship" else 9),"Correct idle and active counts")
		for pose in poses: check(pose.get_size()==Vector2(360,320),"Fixed canvas")
	check(building.specialize("scholarship"),"Remaining Office specialization works")
	building.show_income(5)
	check(building.sprite.texture==building.frames[8],"First active pose")
	building._process(0.16)
	check(building.sprite.texture==building.frames[9],"Second active pose")
	building.show_income(5)
	check(building.active_time==0.3,"Rapid Office income restarts reaction")
	building._process(0.31)
	check(building.active_time==0 and building.sprite.texture in building.frames.slice(0,8),"Returns to eight-pose idle")
	main.free()
	print("BUILDING REFRESH: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)

