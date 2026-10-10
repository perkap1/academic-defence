extends "res://tests/test_integration.gd"
const Blockers=preload("res://scripts/site_blockers.gd")
func run() -> void:
 var seen=[]
 for data in [["main",3],["main_map2",3],["main_map3",5],["main_map4",5]]:
  var packed=load("res://scenes/%s.tscn" % data[0])
  var main=packed.instantiate()
  root.add_child(main)
  main.process_mode=Node.PROCESS_MODE_DISABLED
  var blocked=[]
  for slot in main.map.slots.get_children():
   if slot.is_blocked():
    blocked.append(slot.get_index())
    if slot.blocked_variant not in seen:seen.append(slot.blocked_variant)
    var original=slot.obstacle.texture
    var anchor:Vector2=slot.obstacle.position
    slot.set_hover(true)
    check(slot.obstacle.texture!=original and slot.obstacle.position==anchor,"Hover swaps only texture at fixed origin")
    check(slot.obstacle.texture.get_size()==original.get_size(),"Paired canvases match")
    slot.set_hover(false)
    check(slot.obstacle.texture==original,"Mouse exit restores normal")
    check(slot.obstacle.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"Crisp blocker")
  check(blocked.size()==data[1],"One third blocked on %s" % data[0])
  var slot=main.map.slots.get_child(blocked[0])
  var variant:String=slot.blocked_variant
  var cost:int=slot.get_clear_cost()
  main.game.gold=cost-1
  main.select_slot(slot)
  check(main.ui.clear_menu.visible and not main.ui.build_menu.visible,"Click opens clearing instead of building")
  check(main.ui.clear_button.disabled and main.ui.clear_price.text.contains(str(cost)),"Unaffordable UI shows price")
  check(not main.clear_site(slot) and main.game.gold==cost-1 and slot.is_blocked(),"No funds leaves blocker intact")
  main.game.gold=1000
  main.update_ui()
  check(not main.ui.clear_button.disabled,"Live KP refresh enables clearing")
  check(not main.game.try_build(slot,"book"),"Manager refuses blocked construction")
  main.build(slot,"book")
  check(not slot.occupied and main.game.gold==1000,"Controller refuses blocked construction")
  paused=true
  check(not main.game.try_clear_site(slot),"Pause prevents clearing")
  paused=false
  check(main.clear_site(slot) and main.game.gold==1000-cost,"Clear charges exactly once")
  check(not slot.is_blocked() and not slot.obstacle.visible and not main.ui.clear_menu.visible,"Clear exposes normal slot and closes menu")
  check(not main.game.try_clear_site(slot) and main.game.gold==1000-cost,"Duplicate clear cannot charge")
  main.select_slot(slot)
  check(main.ui.build_menu.visible,"Cleared site opens radial build menu")
  main.build(slot,"book")
  var tower=slot.tower
  check(tower.get_upgrade_cost()==100,"Book upgrade one is100")
  main.select_slot(slot)
  check(main.upgrade(slot) and tower.get_upgrade_cost()==200,"Book upgrade two is200")
  check(main.upgrade(slot) and tower.total_invested==370,"Book investment excludes clearing")
  check(main.sell(slot) and main.game.gold==815-cost,"Sale refunds185, never clearing")
  check(not slot.is_blocked(),"Selling never restores blocker")
  main.build(slot,"blackboard")
  tower=slot.tower
  check(tower.get_upgrade_cost()==120,"Science upgrade one is120")
  main.select_slot(slot)
  check(main.upgrade(slot) and tower.get_upgrade_cost()==220,"Science upgrade two is220")
  check(main.upgrade(slot) and tower.get_sell_refund()==220,"Science full refund220")
  main.sell(slot)
  main.build(slot,"economy")
  main.select_slot(slot)
  main.game.gold=139;main.update_ui()
  check(main.ui.specialization_buttons[0].disabled and not main.specialize(slot,"library"),"Specialization rejects139")
  main.game.gold=140;main.update_ui()
  check(main.ui.specialization_buttons[0].text.contains("140") and not main.ui.specialization_buttons[0].disabled,"Specialization UI price140")
  check(main.specialize(slot,"library") and main.game.gold==0 and slot.tower.get_sell_refund()==120,"Specialization charges140 with refund120")
  check(not main.specialize(slot,"scholarship"),"No double specialization")
  main.free()
  main=packed.instantiate();root.add_child(main)
  main.process_mode=Node.PROCESS_MODE_DISABLED
  check(main.map.slots.get_child(blocked[0]).blocked_variant==variant,"New attempt restores exact blocker")
  main.free()
 check(seen.size()==6,"All six supplied variants used")
 for variant in Blockers.VARIANTS:
  check(Blockers.cost(variant)==(30 if variant.begins_with("school") else (50 if variant.begins_with("nature") else 70)),"Category price")
 var main=load("res://scenes/main_map4.tscn").instantiate()
 root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var slot=main.map.slots.get_child(6)
 for variant in Blockers.VARIANTS:
  slot.set_blocker(variant)
  var price:int=slot.get_clear_cost()
  main.game.gold=price-1
  check(not main.game.try_clear_site(slot) and slot.is_blocked(),"Each variant rejects insufficient funds")
  main.game.gold=price
  check(main.game.try_clear_site(slot) and main.game.gold==0 and not slot.is_blocked(),"Each variant charges exact category price")
 slot.set_blocker("stone_rocks")
 main.select_slot(slot)
 var before:int=main.game.gold
 main.ui.close_build_menu()
 check(slot.is_blocked() and main.game.gold==before and not main.ui.clear_menu.visible,"Cancel has no economic effect")
 main.game.finished=true;main.game.gold=100
 check(not main.game.try_clear_site(slot) and slot.is_blocked(),"Finished round rejects clearing")
 main.free()
 print("BLOCKED SITES: %d checks, %d failures" % [checks,failures])
 quit(1 if failures else 0)

