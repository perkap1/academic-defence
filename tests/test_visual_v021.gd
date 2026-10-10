extends SceneTree
func _initialize():call_deferred("run")
func capture(name):
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v021-"+name+".png"))
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for site in main.map.slots.get_children():site.set_blocker("")
 main.game.gold=10000
 var slot=main.map.slots.get_child(6);main.build(slot,"economy");main.select_slot(slot);main.specialize(slot,"library")
 await capture("library-before")
 main.ui.upgrade_button.pressed.emit();await capture("confirm")
 main.ui.upgrade_confirmation.confirmed.emit();main.ui.upgrade_confirmation.hide()
 await capture("library-gold")
 for i in range(9):
  slot.tower.sprite.texture=slot.tower.frames[i];await capture("library-frame%d"%i)
 main.ui.stats_button.pressed.emit();await capture("library-stats")
 main.sell(slot);main.build(slot,"economy");main.select_slot(slot);main.specialize(slot,"scholarship")
 await capture("office-before")
 main.upgrade(slot);slot.tower.wave_bonus=40;slot.tower.stats.add("kp",10);slot.tower.stats.add("rewarded",2)
 await capture("office-gold")
 for i in range(10):
  slot.tower.sprite.texture=slot.tower.frames[i];await capture("office-frame%d"%i)
 main.ui.stats_button.pressed.emit();await capture("office-stats")
 main.free();quit()
