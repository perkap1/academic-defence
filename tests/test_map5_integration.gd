extends "res://tests/test_integration.gd"
func run():
 seed(2505)
 var layout=load("res://scripts/unit_layout.gd");layout.lane_rng.seed=2505;layout.initialized=true
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var order=[8,14,18,16,9,6,12,13,10,15,17,19,20,7,5,2,3,11,1,4,0]
 for wave in range(22):
  for index in order:
   var slot=main.map.slots.get_child(index)
   var kind="blackboard" if index in [10,13,19] else "book"
   var cost=100 if kind=="blackboard" else 70
   if not slot.occupied and main.game.gold>=cost+slot.get_clear_cost():
    if slot.is_blocked():main.game.try_clear_site(slot)
    main.build(slot,kind)
  for index in order:
   var slot=main.map.slots.get_child(index)
   if slot.occupied:
    main.select_slot(slot)
    while main.upgrade(slot):pass
  check(main.waves.start_wave(),"Ordinary budget starts wave%d"%(wave+1))
  simulate(main,220)
  print("MAP5 WAVE%d lives=%d gold=%d graduates=%d towers=%d"%[wave+1,main.game.lives,main.game.gold,main.game.graduated,main.map.towers.get_child_count()])
  check(not main.waves.active,"Wave resolves completely")
  if main.game.finished:break
 check(main.game.won and main.waves.wave==22,"Ordinary-budget strategy wins22waves")
 check(main.game.graduated+main.game.escaped==main.waves.counts.reduce(func(a,b):return a+b,0),"All students resolve exactly once")
 check(5 in root.get_node("Progression").completed_levels,"Victory saves Map5")
 main.free()
 print("MAP5 INTEGRATION: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
