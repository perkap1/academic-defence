extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 await process_frame;await RenderingServer.frame_post_draw
 var baseline=root.get_texture().get_image()
 var scale_x:float=baseline.get_width()/1672.0;var scale_y:float=baseline.get_height()/1131.0
 var roof:Rect2=main.map.BRIDGE_COVER
 roof.position+=main.map.global_position
 for y in [490,455,410,340,300]:
  var at:float=main.map.lower_route.curve.get_closest_offset(Vector2(920,y))
  var ball=tower.launch_ball(main.map.lower_route,at);ball.state="rolling";ball.global_position=ball.landing;ball.update_visual();ball.set_process(false)
  await process_frame;await RenderingServer.frame_post_draw
  var picture=root.get_texture().get_image();var inside=0;var outside=0
  for py in range(maxi(0,int((roof.position.y-90)*scale_y)),mini(picture.get_height(),int((roof.end.y+110)*scale_y))):
   for px in range(int((roof.position.x-40)*scale_x),int((roof.end.x+40)*scale_x)):
    if picture.get_pixel(px,py).is_equal_approx(baseline.get_pixel(px,py)):continue
    if roof.grow(-2).has_point(Vector2(px/scale_x,py/scale_y)):inside+=1
    else:outside+=1
  check(inside==0,"Roof pixels never show the rolling ball or dust y%d"%y)
  check(outside==0 if y==410 else outside>0,"Ball fully vanishes only inside roof and shows outside y%d"%y)
  picture.save_png("res://../../work/ball-tunnel-y%d.png"%y)
  ball.free()
 main.free();print("BALL TUNNEL VISUAL: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
