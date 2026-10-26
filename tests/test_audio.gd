extends "res://tests/test_integration.gd"
func run():
 check(FileAccess.file_exists("res://scripts/sound.gd"),"8-bit sound manager exists")
 if failures:print("AUDIO: %d checks, %d failures"%[checks,failures]);quit(1);return
 var sound=root.get_node("Sound")
 sound.persist_enabled=false
 sound.set_muted(false);sound.set_volume(0.55)
 for key in ["book_throw","book_hit","science_throw","science_hit","pe_throw","pe_burst","build","upgrade","graduate"]:
  check(sound.bank.has(key) and sound.bank[key].get_length()>0.03 and sound.bank[key].get_length()<0.8,"Short original effect loads: "+key)
 check(sound.play_effect("book_throw"),"First shot plays")
 check(not sound.play_effect("book_throw"),"Simultaneous identical shots are rate limited")
 sound.set_muted(true)
 check(not sound.play_effect("graduate"),"Mute blocks new effects")
 for player in sound.players:check(not player.playing,"Mute immediately silences active effects")
 sound.set_muted(false);sound.set_volume(2.0)
 check(sound.volume==1.0,"Volume clamps to full scale")
 sound.set_volume(-1)
 check(sound.volume==0 and not sound.play_effect("build"),"Zero volume suppresses new effects")
 sound.set_volume(0.55);sound._process(1.0)
 for key in ["book_throw","book_hit","science_throw","science_hit","pe_throw","pe_burst"]:sound.play_effect(key)
 for i in range(20):sound.play_effect("book_throw")
 var active=0
 for remaining in sound.voice_remaining:
  if remaining>0:active+=1
 check(active==6 and sound.players.size()==10,"Combat has a bounded pool with room for important events")
 check(sound.play_effect("graduate"),"Important cue plays even when combat voices are full")
 sound.set_muted(true);sound.set_muted(false);sound._process(1)
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var slot=main.map.slots.get_child(0);slot.set_blocker("")
 main.build(slot,"book")
 check(was_assigned(sound,"build"),"Successful construction triggers building sound")
 sound._process(1);main.game.gold=1000;main.select_slot(slot);main.upgrade(slot)
 check(was_assigned(sound,"upgrade"),"Upgrade triggers upgrade sound")
 sound._process(1)
 var student=load("res://scenes/student.tscn").instantiate();main.map.route.add_child(student)
 student.resolved.connect(main.student_resolved);student.teach(100)
 check(was_assigned(sound,"graduate"),"Graduation triggers positive cue through existing resolution")
 main.free()
 var original_path=sound.save_path
 sound.save_path="user://test_audio_settings.cfg";sound.persist_enabled=true
 sound.set_volume(0.37);sound.set_muted(true)
 sound.persist_enabled=false;sound.set_volume(0.8);sound.set_muted(false);sound.load_settings()
 check(is_equal_approx(sound.volume,0.37) and sound.muted,"Volume and mute survive save and reload")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sound.save_path));sound.save_path=original_path
 sound.set_muted(false);sound.set_volume(0.55)
 sound.set_muted(true)
 await create_timer(0.15).timeout # Let the real audio mixer release stopped playbacks.
 print("AUDIO: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
func was_assigned(sound,key:String)->bool:
 for player in sound.players:
  if player.stream==sound.bank[key]:return true
 return false
