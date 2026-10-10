extends SceneTree
func _initialize():call_deferred("run")
func capture(name):
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v020-"+name+".png"))
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for slot in main.map.slots.get_children():slot.set_blocker("")
 main.game.gold=10000
 var slot=main.map.slots.get_child(6);main.build(slot,"book")
 slot.tower.stats.add("knowledge",300);slot.tower.stats.add("graduated",3);main.game.try_upgrade(slot)
 slot.tower.stats.add("knowledge",500);slot.tower.stats.add("graduated",5);main.game.try_upgrade(slot)
 slot.tower.stats.add("knowledge",700);slot.tower.stats.add("graduated",7);slot.tower.stats.add("shots",38);slot.tower.stats.add("hits",33)
 main.select_slot(slot);main.ui.stats_button.pressed.emit();await capture("book")
 main.sell(slot);main.build(slot,"economy");main.select_slot(slot)
 slot.tower.stats.add("kp",90);slot.tower.stats.add("waves",6);main.specialize(slot,"scholarship")
 slot.tower.stats.add("kp",140);slot.tower.stats.add("rewarded",28);slot.tower.wave_bonus=25
 main.ui.stats_button.pressed.emit();await capture("office")
 main.ui.stats_button.pressed.emit();await capture("office-info")
 main.sell(slot);main.build(slot,"assistant");main.select_slot(slot);main.ui.stats_button.pressed.emit();await capture("assistant")
 main.free();quit()
