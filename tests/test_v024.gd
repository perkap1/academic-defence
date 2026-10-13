extends "res://tests/test_integration.gd"
func run():
 for scene in ["main","main_map2","main_map3","main_map4","main_map5"]:
  var main=load("res://scenes/%s.tscn"%scene).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for wave in [3,4,7,11,19]:
   for kind in ["normal","pe","bookworm","snack","pilot"]:
    main.waves.wave=wave;main.waves.active=true;main.waves.remaining=1
    main.game.student_reward_remainder=0
    var total:int=main.game.gold
    for i in range(2):
     var name="student" if kind in ["normal","pe"] else ("paper_plane_pilot" if kind=="pilot" else ("snack_monster" if kind=="snack" else "bookworm"))
     var unit=load("res://scenes/%s.tscn"%name).instantiate();unit.configure(kind);main.map.route.add_child(unit);unit.resolved.connect(main.student_resolved)
     if kind=="bookworm":
      for hit in range(3):unit.teach(100)
     if kind=="snack":unit.teach(200);unit._process(2.0);unit.teach(300)
     elif kind=="pilot":unit.receive_attack(150,"book")
     else:unit.teach(100)
    var base:int=5 if kind in ["normal","pe","bookworm"] and wave>=4 else 10
    var expected:int=base*2*main.game.get_student_reward_percent(wave)/100
    check(main.game.gold-total==expected,"%s wave%d %s reduced base with exact rounding"%[scene,wave,kind])
  main.free()
 print("V024: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
