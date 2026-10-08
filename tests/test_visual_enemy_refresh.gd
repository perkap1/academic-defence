extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var stage=Node2D.new()
	root.add_child(stage)
	for direction in ["front","side","back"]:
		for child in stage.get_children(): child.free()
		for row in range(7):
			var frames: Dictionary
			var factor: float
			var pivot: Vector2
			var caption: String
			if row==0:
				frames=load("res://scripts/normal_student_frames.gd").create()
				factor=0.28
				pivot=Vector2(150,310)
				caption="Normal"
			elif row<3:
				frames=load("res://scripts/pe_student_frames.gd").create("boy" if row==1 else "girl")
				factor=0.43
				pivot=Vector2(110,210)
				caption="PE boy" if row==1 else "PE girl"
			else:
				frames=load("res://scripts/bookworm_frames.gd").create(6-row)
				factor=0.73
				pivot=Vector2(90,190)
				caption="Bookworm %d books"%(6-row)
			var label=Label.new()
			label.text=caption
			label.position=Vector2(20,120+row*140)
			stage.add_child(label)
			for frame in range(6):
				var sprite=Sprite2D.new()
				sprite.texture=frames[direction][frame]
				sprite.centered=false
				sprite.flip_h=row==2 and direction=="side" and frame in [2,3,4]
				sprite.offset=-pivot
				sprite.scale=Vector2.ONE*factor*1.4
				sprite.position=Vector2(370+frame*215,165+row*140)
				stage.add_child(sprite)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-enemies-%s.png"%direction))
	stage.free()
	quit()
