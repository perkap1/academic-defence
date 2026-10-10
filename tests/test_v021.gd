extends "res://tests/test_integration.gd"
func run():
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 for site in main.map.slots.get_children():site.set_blocker("")
 main.game.gold=10000
 var slot=main.map.slots.get_child(0);main.build(slot,"economy");main.select_slot(slot)
 var before:int=main.game.gold
 main.specialize(slot,"library")
 check(main.game.gold==before-120,"Library specialization charges120")
 var building=slot.tower
 main.economy.complete_wave(1)
 before=main.game.gold;main.ui.upgrade_button.pressed.emit()
 check(main.ui.upgrade_confirmation.visible and main.game.gold==before,"Arrow opens confirmation without charge")
 main.ui.upgrade_confirmation.canceled.emit();main.ui.upgrade_confirmation.hide()
 check(main.game.gold==before and building.get_income()==30,"Cancel leaves income and money unchanged")
 main.game.gold=29;check(not main.game.try_upgrade(slot),"Unaffordable Library upgrade rejected");main.game.gold=before
 main.ui.upgrade_button.pressed.emit();main.ui.upgrade_confirmation.confirmed.emit();main.ui.upgrade_confirmation.hide()
 check(main.game.gold==before-30,"Confirmed Library upgrade charges once")
 if building.get("level")==null:
  main.free();print("V021: %d checks, %d failures"%[checks,failures]);quit(1);return
 check(building.level==2 and building.get_income()==35,"Library upgrade increases income")
 check(building.stats.total.get("kp",0)==30 and building.stats.current().get("kp",0)==0,"Upgrade preserves total and resets stage")
 check(building.sprite.material.get_shader_parameter("gold_banner")==true and building.base_sprite.material.get_shader_parameter("gold_banner")==true,"Both artwork layers use gold banner")
 main.ui.upgrade_button.pressed.emit();main.ui.upgrade_confirmation.confirmed.emit();main.ui.upgrade_confirmation.hide()
 check(main.game.gold==before-30,"Max repeated confirmation cannot charge twice")
 main.economy.complete_wave(2)
 check(building.stats.total.kp==65 and building.stats.current().kp==35,"Upgraded income counted once")
 check(not main.game.try_upgrade(slot) and building.get_sell_refund()==125,"Max Library rejects duplicate and refunds125")
 main.sell(slot);main.build(slot,"economy");main.select_slot(slot);before=main.game.gold
 main.specialize(slot,"scholarship");building=slot.tower
 check(main.game.gold==before-150,"Office specialization charges150")
 main.waves.active=true;main.waves.remaining=1;main.economy.begin_wave(3)
 for i in range(8):graduate(main,building)
 check(building.wave_bonus==40,"Office reaches original cap40")
 before=main.game.gold;check(main.game.try_upgrade(slot),"Office upgrade allowed at cap")
 check(main.game.gold==before-50 and building.wave_bonus==40,"Office upgrade costs50 and retains current wave")
 for i in range(4):graduate(main,building)
 check(building.wave_bonus==50 and building.stats.total.kp==50 and building.stats.current().kp==10,"Expanded cap permits exactly two more graduates")
 check(building.stats.total.waves==1 and building.stats.current().waves==1,"Same wave counts once in lifetime and once in upgraded stage")
 check(building.stats.total.rewarded==10 and building.stats.current().rewarded==2,"No duplicate statistics through upgrade")
 check(building.get_income()==0 and building.get_sell_refund()==150,"Office no passive income and refund150")
 main.economy.begin_wave(4);check(building.wave_bonus==0,"Expanded Office resets wave cap")
 main.sell(slot);main.build(slot,"book");main.game.try_upgrade(slot);before=main.game.gold;main.game.try_upgrade(slot)
 check(main.game.gold==before-220 and slot.tower.get_sell_refund()==195,"Book L3 costs220 refund195")
 main.sell(slot);main.build(slot,"blackboard");main.game.try_upgrade(slot);before=main.game.gold;main.game.try_upgrade(slot)
 check(main.game.gold==before-250 and slot.tower.get_sell_refund()==235,"Science L3 costs250 refund235")
 animation_checks(main,slot)
 main.free();print("V021: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
func graduate(main,building):
 var student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student);student.global_position=building.global_position
 student.resolved.connect(main.student_resolved);student.teach(100)

func animation_checks(main,slot):
 main.sell(slot);main.build(slot,"assistant");var post=slot.tower
 for vector in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP,Vector2(1,1),Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1)]:
  post.point_at(post.global_position+vector*100);post._process(0.1)
  check(post.sprite.texture==post.point_frames[0],"Pointing first pose lasts one sixth second")
  post._process(0.1);check(post.sprite.texture==post.point_frames[1],"Pointing second pose at6FPS")
  post._process(0.31);check(post.point_remaining==0 and post.sprite.texture in post.idle_frames,"All directions return to idle")
 post.animation_time=0;post._process(0.2);check(post.sprite.texture==post.idle_frames[0],"Desk idle holds at3FPS")
 post._process(0.14);check(post.sprite.texture==post.idle_frames[1],"Desk idle advances at3FPS")
 main.sell(slot);main.build(slot,"economy");var building=slot.tower
 for branch in ["study","library","scholarship"]:
  building.branch=branch;building.apply_artwork();building.visual_time=0;building.active_time=0
  building._process(0.2);check(building.sprite.texture==building.frames[0],"Economy idle holds at3FPS")
  building._process(0.14);check(building.sprite.texture==building.frames[1],"Economy idle advances at3FPS")
  building.show_income(5);building._process(0.1);check(building.sprite.texture==building.frames[8],"Income active first frame visible")
  if branch != "scholarship":
   building._process(0.1);check(building.active_time>0 and building.sprite.texture==building.frames[8],"Single active frame keeps readable hold")
  building._process(0.3);check(building.active_time==0,"Income active returns to idle")
