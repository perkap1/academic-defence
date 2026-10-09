extends SceneTree
func _initialize():call_deferred("run")
func capture(name):
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v019-"+name+".png"))
func run():
 var progress=root.get_node("Progression");progress.persist_enabled=false
 progress.completed_levels.assign([1,2,3]);progress.best_stars={1:3,2:2,3:1}
 var world=load("res://scenes/world_map.tscn").instantiate();root.add_child(world)
 await capture("world");world.free()
 var main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.game.gold=1000
 var slot=main.map.slots.get_child(6);slot.set_blocker("");main.build(slot,"blackboard")
 var s=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(s);s.progress=1000;s.lane_offset=0;s.update_lane_position();s.teach(40)
 slot.tower.global_position=s.global_position+Vector2(180,-80);slot.tower._process(0)
 var shot=main.map.effects.get_child(main.map.effects.get_child_count()-1);shot.advance(0.35)
 await capture("arc")
 s._process(0.7);shot.advance(0.35)
 await capture("impact")
 main.game.won=true;main.game.lives=8;main.ui.show_result(true,main.game,17,17)
 await create_timer(1.6).timeout
 await capture("victory");main.free();quit()

