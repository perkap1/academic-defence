extends "res://tests/test_pe_teacher.gd"
func run():
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for kind in ["normal","pe","bookworm"]:
  for sex in (["boy","girl"] if kind=="pe" else ["boy"]):
   var unit=pupil(main,kind,main.map.route,400,sex)
   var capacity:float=100 if kind=="normal" else 90
   check(unit.bar.max_value==capacity and unit.get_heal_capacity()==capacity,"Correct health and healing capacity for "+kind)
   if kind=="bookworm":
    for hit in range(3):unit.receive_attack(1000,"book")
    check(unit.books==0 and unit.knowledge==0,"All three Bookworm shields remain")
   unit.receive_attack(int(capacity)-1,"book")
   check(not unit.done,"Student remains active one point before new threshold")
   unit.receive_attack(1,"book")
   check(unit.done and unit.knowledge==capacity,"Exactly reaching new threshold graduates student")
   unit.free()
 var tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 for level in range(1,4):
  if level>1:tower.upgrade_level()
  check(tower.knowledge_per_hit==[50,65,80][level-1],"PE Teacher follows current damage balance")
  check(is_equal_approx(tower.fire_interval,[3.8,3.7,3.6][level-1]),"PE Teacher follows current cast intervals")
  check(tower.roll_distance==[240,300,360][level-1],"PE Teacher follows current roll distances")
 main.free();print("BALANCE V0314: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
