extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 check(main.map.has_method("bridge_visibility"),"Bridge exposes gradual visible body fraction")
 if not main.map.has_method("bridge_visibility"):main.free();print("BRIDGE TRANSITION: missing progressive clipping");quit(1);return
 for kind in ["normal","pe","bookworm","snack","pilot","clown"]:
  var scene="class_clown" if kind=="clown" else ("paper_plane_pilot" if kind=="pilot" else ("bookworm" if kind=="bookworm" else ("snack_monster" if kind=="snack" else "student")))
  var unit=load("res://scenes/%s.tscn"%scene).instantiate();unit.configure(kind);main.map.lower_route.add_child(unit);unit.lane_offset=0
  var fractions=[];var entry_partial=false;var exit_partial=false;var hidden=false
  for y in range(560,279,-2):
   unit.progress=main.map.lower_route.curve.get_closest_offset(Vector2(920,y));unit.update_lane_position()
   var fraction:float=main.map.bridge_visibility(unit)
   check(unit.can_receive_attack("book")== (fraction>0),"Targetable iff some actual body remains visible")
   if kind=="pilot":check(fraction==1 and unit.visible,"Pilot always visible above bridge")
   elif fraction==0:hidden=true;check(not unit.visible,"Fully hidden body disables whole unit UI")
   elif fraction<1:
    if hidden:exit_partial=true
    else:entry_partial=true
    check(unit.sprite.material!=null and unit.visible,"Partial body uses spatial clipping and stays visible")
  if kind!="pilot":check(entry_partial and hidden and exit_partial,"Entry clips gradually, fully hides, then exit reveals gradually")
  unit.free()
 var site=main.map.slots.get_child(11);site.set_blocker("");main.game.gold=1000;main.build(site,"book")
 var pupil=load("res://scenes/student.tscn").instantiate();main.map.lower_route.add_child(pupil);pupil.lane_offset=0
 var shots=0
 for y in [480,440,370,300]:
  pupil.progress=main.map.lower_route.curve.get_closest_offset(Vector2(920,y));pupil.update_lane_position()
  site.tower.cooldown=0;site.tower._process(0)
  if y!=440:shots+=1
  check(main.map.projectiles.get_child_count()==shots,"Tower fires during entry and emergence, stops only when fully hidden")
 pupil.progress=main.map.lower_route.curve.get_closest_offset(Vector2(920,440));pupil.update_lane_position()
 for shot in main.map.projectiles.get_children():shot._process(1)
 check(pupil.knowledge==0,"Shots launched earlier cannot hit a fully hidden student")
 main.free();print("BRIDGE TRANSITION: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
