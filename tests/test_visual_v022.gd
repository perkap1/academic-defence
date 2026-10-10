extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.waves.wave=11;main.waves.active=true;main.waves.remaining=1
 var student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student);student.progress_ratio=0.5
 student.resolved.connect(main.student_resolved);student.teach(100)
 main.update_ui()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v022-reward.png"))
 main.free();quit()
