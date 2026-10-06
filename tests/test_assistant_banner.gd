extends SceneTree
var checks=0
var failures=0
func check(ok:bool,message:String):
 checks+=1
 if not ok: failures+=1;print("FAIL: "+message)
func _initialize(): call_deferred("run")
func run():
 for scene in ["main","main_map2"]:
  var main=load("res://scenes/%s.tscn"%scene).instantiate()
  root.add_child(main)
  main.process_mode=Node.PROCESS_MODE_DISABLED
  main.game.gold=1000
  var slot=main.map.slots.get_child(2)
  main.build(slot,"assistant")
  main.select_slot(slot)
  check(main.ui.tower_panel==main.ui.tower_banner,"Assistant uses common banner")
  check(main.ui.tower_banner.visible,"Bottom banner visible")
  check(main.ui.banner_title.text=="Teaching Assistant Post","Assistant title")
  check(main.ui.upgrade_button.disabled,"Upgrade disabled")
  check(main.ui.upgrade_caption.text=="Ingen upgrades","Unavailable caption")
  check(main.ui.banner_sell.text=="SELL · +60 KP","Half refund")
  check(slot.tower.show_range and slot.tower.marker.visible,"Range and rally shown")
  check(not main.game.try_upgrade(slot) and main.game.gold==880,"Upgrade cannot charge")
  var rally:Vector2=slot.tower.rally_point
  check(slot.tower.try_move_rally(rally),"Rally movement retained")
  main.clear_selection()
  check(not main.ui.tower_banner.visible and not slot.tower.show_range,"Deselect hides banner and range")
  main.select_slot(slot)
  check(main.sell(slot) and main.game.gold==940,"Selling preserved")
  await process_frame
  main.free()
 print("ASSISTANT BANNER: %d checks, %d failures"%[checks,failures])
 quit(1 if failures else 0)

