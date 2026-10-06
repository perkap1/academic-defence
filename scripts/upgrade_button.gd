extends Button
const Presentation=preload("res://scripts/tower_presentation.gd")
var state_frames:=[]
var last_state:=-1
func _ready()->void:
 state_frames=Presentation.arrow_frames()
 for state in ["normal","hover","pressed","disabled","focus"]:
  add_theme_stylebox_override(state,StyleBoxEmpty.new())
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func get_state_index()->int:
 if disabled:return 3
 if is_pressed():return 2
 return 1 if is_hovered() else 0
func _process(_delta:float)->void:
 var state=get_state_index()
 if state!=last_state:
  last_state=state
  queue_redraw()
func _draw()->void:
 if state_frames.is_empty():return
 var texture:Texture2D=state_frames[get_state_index()]
 var factor=minf(size.x/texture.get_width(),size.y/texture.get_height())
 var dimensions=texture.get_size()*factor
 draw_texture_rect(texture,Rect2((size-dimensions)*0.5,dimensions),false)
