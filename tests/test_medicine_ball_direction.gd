extends "res://tests/test_pe_teacher.gd"
func run():
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 var route=main.map.route
 for points in [[Vector2(0,300),Vector2(900,300)],[Vector2(300,0),Vector2(300,900)],[Vector2(100,100),Vector2(750,750)],[Vector2(0,400),Vector2(300,400),Vector2(500,200),Vector2(800,200)]]:
  route.curve=main.map.create_route_curve(points)
  for sign in [-1,1]:
   var at:float=route.curve.get_baked_length()*0.5
   var landing:Vector2=route.to_global(route.curve.sample_baked(at))
   var tangent:Vector2=route.global_transform.basis_xform(load("res://scripts/unit_layout.gd").tangent(route.curve,at)).normalized()
   tower.global_position=landing-tangent*100*sign
   var normal=pupil(main,"normal",route,at+sign*100)
   var worm=pupil(main,"bookworm",route,at+sign*145)
   var ball=tower.launch_ball(route,at)
   ball.advance(ball.FLIGHT_TIME);ball.advance(0.65)
   check(is_equal_approx(ball.progress,at+sign*195),"Ball rolls along road in throw direction, including against students")
   check(normal.knowledge==50,"Reverse swept collision hits units between frame endpoints")
   check(worm.books==2 and worm.knowledge==0,"Reverse rolling removes only one Bookworm shield")
   ball.advance(0.1);check(worm.books==2,"Reverse overlap cannot hit same pupil twice")
   ball.advance(1)
   check(ball.state=="burst" and ball.distance_travelled==240,"Both directions keep doubled roll distance")
   ball.free();normal.free();worm.free()
  for sign in [-1,1]:
   var at:float=25 if sign<0 else route.curve.get_baked_length()-25
   var landing:Vector2=route.to_global(route.curve.sample_baked(at))
   var tangent:Vector2=load("res://scripts/unit_layout.gd").tangent(route.curve,at)
   tower.global_position=landing-tangent*100*sign
   var ball=tower.launch_ball(route,at);ball.advance(ball.FLIGHT_TIME);ball.advance(1)
   check(ball.state=="burst" and is_equal_approx(ball.distance_travelled,25),"Ball bursts at either road boundary without wrapping")
   ball.free()
 # A raised throwing hand must not flip a short upward throw into down-road
 # rolling; use its projection onto the ground rather than the visible arc.
 route.curve=main.map.create_route_curve([Vector2(300,0),Vector2(300,900)])
 tower.global_position=route.to_global(Vector2(300,420))
 var short_throw=tower.launch_ball(route,400);short_throw.advance(short_throw.FLIGHT_TIME);short_throw.advance(0.1)
 check(is_equal_approx(short_throw.progress,370),"Raised hand cannot reverse an upward ground throw")
 short_throw.free()
 # Conversely the actual release point, including its horizontal hand offset,
 # determines the direction of a very short sideways throw.
 route.curve=main.map.create_route_curve([Vector2(0,300),Vector2(900,300)])
 tower.global_position=route.to_global(Vector2(400,300));tower.sprite.flip_h=false
 short_throw=tower.launch_ball(route,420);short_throw.advance(short_throw.FLIGHT_TIME);short_throw.advance(0.1)
 check(is_equal_approx(short_throw.progress,390),"Short throw follows actual hand release rather than tower centre")
 short_throw.free();main.free()
 print("MEDICINE DIRECTION: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
