extends "res://tests/test_integration.gd"
func run():
 for destination in [Vector2(300,0),Vector2(-300,0),Vector2(0,300),Vector2(0,-300),Vector2(240,180),Vector2(-240,-180)]:
  var shot=load("res://scripts/science_attack.gd").new()
  shot.configure_science(1,105);root.add_child(shot);shot.global_position=destination;shot.launch_from(Vector2.ZERO)
  for t in [0.0,0.15,0.35,0.55,0.85]:
   shot.advance(t*shot.FLIGHT_TIME-shot.elapsed)
   var tangent=-shot.launch_offset+Vector2(0,65-4*shot.ARC_HEIGHT+8*shot.ARC_HEIGHT*t)
   check(Vector2.RIGHT.rotated(shot.orb.rotation).dot(tangent.normalized())>0.999,"Round head leads actual arc tangent in every direction")
  shot.free()
 print("SCIENCE DIRECTION: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
