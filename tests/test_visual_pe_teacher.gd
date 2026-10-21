extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map2.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED;main.game.gold=3000
 for slot in main.map.slots.get_children():slot.set_blocker("")
 main.build(main.map.slots.get_child(1),"pe_teacher")
 main.build(main.map.slots.get_child(3),"pe_teacher")
 main.build(main.map.slots.get_child(5),"pe_teacher")
 for i in range(3):
  var tower=main.map.towers.get_child(i)
  for j in range(i):tower.upgrade_level()
 main.select_slot(main.map.slots.get_child(3))
 var tower=main.map.towers.get_child(1)
 tower.animation_time=0.25;tower.update_sprite(0)
 var ball=tower.launch_ball(main.map.route,1000);ball.advance(ball.FLIGHT_TIME);ball.advance(0.08)
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/pe-gameplay.png")
 main.select_slot(main.map.slots.get_child(0))
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/pe-menu.png")
 # Close-up comparison, anchored bases across idle and every throw frame.
 main.free()
 var scene=Node2D.new();root.add_child(scene)
 for i in range(18):
  var t=load("res://scenes/pe_teacher.tscn").instantiate();scene.add_child(t)
  var frame=i%9
  t.position=Vector2(110+(frame%5)*320,250+int(frame/5)*250+int(i/9)*540);t.scale=Vector2.ONE*1.6
  t.sprite.flip_h=i>=9;t.base_sprite.flip_h=i>=9
  t.animation_time=0 if frame<4 else (0.8-(frame-4)*0.16-0.001)
  t.visual_time=frame*0.5;t.update_sprite(0)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/pe-animation.png")
 scene.free();quit()
