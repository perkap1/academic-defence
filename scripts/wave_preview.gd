extends Control
const Artwork=preload("res://scripts/ui_skin.gd")
const KINDS=["normal","pe","bookworm","snack","pilot"]
const NAMES={"normal":"Normal Student","pe":"PE Student","bookworm":"Bookworm","snack":"Snack Monster","pilot":"Paper Plane Pilot"}
class EntranceIcon extends Button:
 func _draw()->void:
  var gold=Color("ffe47b") if is_hovered() else Color("dfac36")
  draw_rect(Rect2(5,3,38,42),Color("102820"))
  draw_rect(Rect2(9,3,30,42),gold)
  draw_rect(Rect2(5,7,38,34),gold)
  draw_rect(Rect2(9,7,30,34),Color("3d301d"))
  draw_rect(Rect2(20,11,8,18),Color("fff0a0"))
  draw_rect(Rect2(20,33,8,6),Color("fff0a0"))
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
  var icon=EntranceIcon.new();icon.name="Entrance%d"%entry;icon.size=Vector2(48,48)
  icon.focus_mode=Control.FOCUS_NONE
  for state in ["normal","hover","pressed","focus"]:icon.add_theme_stylebox_override(state,StyleBoxEmpty.new())
  icon.position=entrance_position(level.get_routes()[entry])-icon.size/2
  add_child(icon);icons[entry]=icon
  icon.mouse_entered.connect(func():show_entry(entry))
  icon.mouse_exited.connect(func():
   if not pinned and selected_entry==entry:hide_panel())
  icon.pressed.connect(func():
   if touch_input and pinned and selected_entry==entry:hide_panel()
   else:show_entry(entry,touch_input))
 # Panel stays above the icons while its contents never intercept input.
 move_child(panel,get_child_count()-1)
func entrance_position(path:Path2D)->Vector2:
 var board=Rect2(level_map.global_position,Vector2(1672,941))
 var point:Vector2=path.global_position
 var distance:=0.0
 while distance<=path.curve.get_baked_length():
  point=path.to_global(path.curve.sample_baked(distance))
  if board.has_point(point):break
  distance+=8.0
 var tangent=preload("res://scripts/unit_layout.gd").tangent(path.curve,distance)
 var normal=Vector2(-tangent.y,tangent.x)
 var best:=Vector2.ZERO;var best_score:=-INF
 for offset in [-70.0,70.0,-100.0,100.0]:
  var candidate=point+normal*offset
  candidate.x=clampf(candidate.x,32,1640);candidate.y=clampf(candidate.y,222,1099)
  var score:=INF
  for slot in level_map.slots.get_children():score=minf(score,candidate.distance_to(slot.global_position)-90)
  # Keep clear of visible road centers as well as building hit circles.
  score=minf(score,candidate.distance_to(level_map.nearest_road_point(candidate))-42)
  for icon in icons.values():score=minf(score,candidate.distance_to(icon.position+Vector2(24,24))-60)
  if score>best_score:best=candidate;best_score=score
 return best.round()
func entry_name(entry:int)->String:
 if level_map.level_id==5:return ["A: UPPER LEFT","B: LOWER LEFT","C: TOP","D: BOTTOM"][entry]
 if level_map.get_routes().size()==2:return "UPPER PATH" if entry==0 else "LOWER PATH"
 return "ENTRANCE"
func enemy_texture(kind:String)->Texture2D:
 if textures.has(kind):return textures[kind]
 var frames:Dictionary
 match kind:
  "normal":frames=preload("res://scripts/normal_student_frames.gd").create()
  "pe":frames=preload("res://scripts/pe_student_frames.gd").create("boy")
  "bookworm":frames=preload("res://scripts/bookworm_frames.gd").create(3)
  "snack":frames=preload("res://scripts/snack_frames.gd").create()
  "pilot":frames=preload("res://scripts/pilot_frames.gd").create()
 textures[kind]=frames["side" if kind=="pilot" else "front"][0]
 return textures[kind]
func show_entry(entry:int,keep_open:bool=false)->void:
 if not icons.has(entry) or wave_manager.active or wave_manager.game.finished:return
 selected_entry=entry;pinned=keep_open
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
  var image=TextureRect.new();image.texture=enemy_texture(kind);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  image.position=Vector2(65,74+row*36);image.size=Vector2(36,36);image.mouse_filter=Control.MOUSE_FILTER_IGNORE;panel.add_child(image)
  row_labels[kind]=Artwork.label(panel,"%s x %d"%[NAMES[kind],mix[kind]],Vector2(110,78+row*36),Vector2(305,28),20)
  total+=int(mix[kind]);row+=1
 total_label=Artwork.label(panel,"TOTAL: %d STUDENTS"%total,Vector2(65,90+row*36),Vector2(350,28),20,Color("ffe47b"))
 var origin:Vector2=icons[entry].position
 var position_hint=origin+Vector2(60,0)
 if position_hint.x+dimensions.x>1664:position_hint.x=origin.x-dimensions.x-12
 position_hint.x=clampf(position_hint.x,8,1664-dimensions.x)
 position_hint.y=clampf(position_hint.y,198,1123-dimensions.y)
 panel.position=position_hint.round();panel.show()
func hide_panel()->void:
 if is_instance_valid(panel):panel.hide()
 selected_entry=-1;pinned=false
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
func _process(_delta:float)->void:
 visible=not get_tree().paused
 if not visible:hide_panel()
