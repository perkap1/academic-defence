extends Control
const Artwork=preload("res://scripts/ui_skin.gd")
const KINDS=["normal","pe_boy","pe_girl","bookworm","snack","pilot"]
const NAMES={"normal":"Normal Student","pe_boy":"PE Student Boy","pe_girl":"PE Student Girl","bookworm":"Bookworm","snack":"Snack Monster","pilot":"Paper Plane Pilot"}
class EntranceIcon extends TextureButton:
 var elapsed:=0.0
 var hover_preview:=false
 var frames:Array=[]
 func _init()->void:
  ignore_texture_size=true;stretch_mode=TextureButton.STRETCH_SCALE
  texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  for i in range(5):frames.append(load("res://assets/wave_ui/warning_%d.png"%i))
  texture_normal=frames[0];texture_hover=frames[4];texture_pressed=frames[4]
 func get_visual_frame()->int:return 4 if is_hovered() or hover_preview else 0
 func _process(delta:float)->void:
  elapsed+=delta
  texture_normal=frames[get_visual_frame()]
var icons:Dictionary={}
var composition:Dictionary={}
var panel:Control
var total_label:Label
var row_labels:Dictionary={}
var level_map
var wave_manager
var cached_wave:=-1
var selected_entry:=-1
var pinned:=false
var touch_input:=false
var textures:Dictionary={}
var dismiss_delay:=0.15
func _ready()->void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 z_index=20
 panel=Control.new();panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.hide();add_child(panel)
func clear_icons()->void:
 hide_panel()
 for icon in icons.values():icon.free()
 icons.clear();composition.clear();cached_wave=-1
func refresh(level,waves)->void:
 level_map=level;wave_manager=waves
 if waves.active or waves.game.finished or waves.wave>=waves.counts.size():
  if not icons.is_empty():clear_icons()
  return
 var next_wave:int=waves.wave+1
 if cached_wave==next_wave:return
 clear_icons();cached_wave=next_wave
 composition=waves.get_next_wave_preview()
 for entry in composition:
  var icon=EntranceIcon.new();icon.name="Entrance%d"%entry;icon.size=Vector2(64,64)
  icon.focus_mode=Control.FOCUS_NONE
  for state in ["normal","hover","pressed","focus"]:icon.add_theme_stylebox_override(state,StyleBoxEmpty.new())
  icon.position=entrance_position(level.get_routes()[entry])-icon.size/2
  add_child(icon);icons[entry]=icon
  icon.mouse_entered.connect(func():show_entry(entry))
  icon.mouse_exited.connect(func():
   if not pinned and selected_entry==entry:dismiss_delay=0.15)
  icon.pressed.connect(func():
   if touch_input and pinned and selected_entry==entry:hide_panel()
   else:show_entry(entry,touch_input))
 # Panel stays above the icons while its contents never intercept input.
 move_child(panel,get_child_count()-1)
func entrance_position(path:Path2D)->Vector2:
 var board=Rect2(level_map.global_position,Vector2(1672,941))
 var distance:=0.0
 while distance<=path.curve.get_baked_length():
  var point=path.to_global(path.curve.sample_baked(distance))
  if board.has_point(point):break
  distance+=8.0
 # Stay on the exact curve, 80 world pixels inside the visible entry.
 distance=minf(distance+80,path.curve.get_baked_length())
 return path.to_global(path.curve.sample_baked(distance)).round()
func entry_name(entry:int)->String:
 if level_map.level_id==2:return "LEFT PATH" if entry==0 else "TOP PATH"
 if level_map.level_id==5:return ["A: UPPER LEFT","B: LOWER LEFT","C: TOP","D: BOTTOM"][entry]
 if level_map.get_routes().size()==2:return "UPPER PATH" if entry==0 else "LOWER PATH"
 return "ENTRANCE"
func enemy_texture(kind:String)->Texture2D:
 if not textures.has(kind):textures[kind]=load("res://assets/wave_ui/mini_%s.png"%kind)
 return textures[kind]
func show_entry(entry:int,keep_open:bool=false)->void:
 if not icons.has(entry) or wave_manager.active or wave_manager.game.finished:return
 selected_entry=entry;pinned=keep_open;dismiss_delay=0.15
 for key in icons:icons[key].hover_preview=key==entry
 for child in panel.get_children():child.free()
 row_labels.clear()
 var mix:Dictionary=composition[entry]
 var dimensions=Vector2(480,190+mix.size()*36)
 panel.size=dimensions
 Artwork.panel(panel,Vector2.ZERO,dimensions,true)
 Artwork.label(panel,"NEXT WAVE %d - %s"%[cached_wave,entry_name(entry)],Vector2(65,40),Vector2(350,26),18,Color("ffe47b"))
 var row:=0;var total:=0
 for kind in KINDS:
  if not mix.has(kind):continue
  var image=TextureRect.new();image.texture=enemy_texture(kind);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_SCALE
  image.position=Vector2(67,76+row*36);image.size=image.texture.get_size()*2;image.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.add_child(image)
  row_labels[kind]=Artwork.label(panel,"%s x %d"%[NAMES[kind],mix[kind]],Vector2(110,78+row*36),Vector2(305,28),20)
  total+=int(mix[kind]);row+=1
 total_label=Artwork.label(panel,"TOTAL: %d STUDENTS"%total,Vector2(65,90+row*36),Vector2(350,28),20,Color("ffe47b"))
 var origin:Vector2=icons[entry].position
 var position_hint=origin+Vector2(76,0)
 if position_hint.x+dimensions.x>1664:position_hint.x=origin.x-dimensions.x-12
 position_hint.x=clampf(position_hint.x,8,1664-dimensions.x)
 position_hint.y=clampf(position_hint.y,198,1123-dimensions.y)
 panel.position=position_hint.round();panel.show()
func hide_panel()->void:
 if is_instance_valid(panel):panel.hide()
 selected_entry=-1;pinned=false
 for icon in icons.values():icon.hover_preview=false
func has_icon_at(point:Vector2)->bool:
 if not is_visible_in_tree():return false
 for icon in icons.values():
  if icon.get_global_rect().has_point(point):return true
 return false
func _input(event:InputEvent)->void:
 if event is InputEventScreenTouch and event.pressed:
  touch_input=true
  var on_icon:=false
  for icon in icons.values():
   if icon.get_global_rect().has_point(event.position):on_icon=true
  if not on_icon:hide_panel()
 elif event is InputEventMouseMotion and event.device!=-1:touch_input=false
 elif event is InputEventMouseButton and event.pressed:
  var on_icon:=false
  for icon in icons.values():
   if icon.get_global_rect().has_point(event.position):on_icon=true
  if not on_icon:hide_panel()
 elif event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:hide_panel()
func _process(delta:float)->void:
 visible=not get_tree().paused
 if not visible:hide_panel();return
 if panel.visible and not pinned and icons.has(selected_entry):
  var pointer=get_global_mouse_position()
  if icons[selected_entry].get_global_rect().has_point(pointer) or panel.get_global_rect().has_point(pointer):dismiss_delay=0.15
  else:
   dismiss_delay-=delta
   if dismiss_delay<=0:hide_panel()
