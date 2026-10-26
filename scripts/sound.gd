extends Node

signal settings_changed
const NAMES:=["book_throw","book_hit","science_throw","science_hit","pe_throw","pe_burst","build","upgrade","graduate"]
const IMPORTANT:=["build","upgrade","graduate"]
const VOICES:=10
const COMBAT_VOICES:=6
var bank:Dictionary={}
var players:Array[AudioStreamPlayer]=[]
var voice_remaining:Array[float]=[]
var cooldowns:Dictionary={}
var volume:=0.55
var muted:=false
var save_path:="user://academic_defence_audio.cfg"
var persist_enabled:=true
var bus_index:=-1

func _ready()->void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 persist_enabled=not OS.get_cmdline_args().has("--script")
 bus_index=AudioServer.get_bus_index("Effects")
 if bus_index<0:
  AudioServer.add_bus();bus_index=AudioServer.bus_count-1
  AudioServer.set_bus_name(bus_index,"Effects")
 for effect in NAMES:bank[effect]=load("res://assets/audio/%s.wav"%effect)
 for i in range(VOICES):
  var player=AudioStreamPlayer.new();player.bus="Effects";player.volume_db=-8
  add_child(player);players.append(player);voice_remaining.append(0.0)
 load_settings();apply_settings()

func _process(delta:float)->void:
 for effect in cooldowns:cooldowns[effect]=maxf(0,float(cooldowns[effect])-delta)
 for i in range(voice_remaining.size()):voice_remaining[i]=maxf(0,voice_remaining[i]-delta)

func play_effect(effect:String)->bool:
 if muted or volume<=0 or not bank.has(effect) or float(cooldowns.get(effect,0))>0:return false
 var important:bool=effect in IMPORTANT
 for i in range(COMBAT_VOICES if not important else VOICES):
  # Reserve four voices for useful feedback during dense combat.
  var index:int=VOICES-1-i if important else i
  var player:AudioStreamPlayer=players[index]
  if voice_remaining[index]<=0:
   player.stream=bank[effect]
   voice_remaining[index]=player.stream.get_length()
   # Dummy has no mixer to release WAV playbacks. Keep the same admission
   # limits for silent servers/tests without allocating inaudible playbacks.
   if AudioServer.get_driver_name()!="Dummy":player.play()
   cooldowns[effect]=0.12 if effect=="graduate" else (0.07 if not important else 0.04)
   return true
 return false

func set_volume(value:float)->void:
 volume=clampf(value,0,1);apply_settings();save_settings();settings_changed.emit()
func set_muted(value:bool)->void:
 muted=value;apply_settings();save_settings();settings_changed.emit()
func apply_settings()->void:
 if bus_index>=0:
  AudioServer.set_bus_volume_db(bus_index,linear_to_db(maxf(volume,0.0001)))
  AudioServer.set_bus_mute(bus_index,muted or volume<=0)
 if muted or volume<=0:
  for player in players:player.stop()
  voice_remaining.fill(0.0)
func save_settings()->void:
 if not persist_enabled:return
 var config=ConfigFile.new();config.set_value("effects","volume",volume);config.set_value("effects","muted",muted)
 if config.save(save_path)!=OK:push_warning("Could not save audio settings")
func load_settings()->void:
 var config=ConfigFile.new()
 if persist_enabled or FileAccess.file_exists(save_path):
  if config.load(save_path)==OK:
   volume=clampf(float(config.get_value("effects","volume",0.55)),0,1)
   muted=bool(config.get_value("effects","muted",false))
 apply_settings();settings_changed.emit()

func open_settings(parent:Node)->void:
 var dialog=preload("res://scripts/audio_settings.gd").new()
 parent.add_child(dialog);dialog.popup_centered(Vector2i(470,250))

func _exit_tree()->void:
 for player in players:
  player.stop()
  player.stream=null
 players.clear()
 bank.clear()
