extends Node2D
var stats = preload("res://scripts/building_stats.gd").new()
const Assistant = preload("res://scripts/teaching_assistant.gd")
var tower_type := "assistant"
func _init() -> void: stats.stage_name = "Post"
var teaching_range := 260.0
var work_radius := 110.0
var show_range := false
var map
var game
var rally_point := Vector2.ZERO
var assistants := []
var marker := Sprite2D.new()
var marker_frames := []
var animation_time := 0.0
var point_remaining := 0.0
var point_direction := "right"
var point_frames := []
var idle_frames := []
var base_sprite: Sprite2D
@onready var sprite: Sprite2D=$Sprite
func _ready() -> void:
 idle_frames=preload("res://scripts/building_frames.gd").post_idle()
 $Sprite.texture=idle_frames[0]
 $Sprite.scale=Vector2.ONE*0.5525
 $Sprite.centered=false
 $Sprite.offset=Vector2(-180,-290)
 $Sprite.position=Vector2(0,-5.5)
 base_sprite=Sprite2D.new()
 base_sprite.texture=idle_frames[0]
 base_sprite.centered=false
 base_sprite.offset=$Sprite.offset
 base_sprite.position=$Sprite.position
 base_sprite.scale=$Sprite.scale
 add_child(base_sprite)
 move_child(base_sprite,0)
 for pair in [[base_sprite,false],[$Sprite,true]]:
  var material=ShaderMaterial.new()
  material.shader=preload("res://scripts/tower_base.gdshader")
  material.set_shader_parameter("cut_y",-70.0)
  material.set_shader_parameter("upper",pair[1])
  pair[0].material=material
 $Sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 base_sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 for i in range(5): marker_frames.append(load("res://assets/assistant/rally_%d.png" % i))
 marker.texture=marker_frames[0]
 marker.scale=Vector2(0.8,0.55)
 marker.visible=false
 add_child(marker)
func configure(level,manager) -> void:
 map=level
 game=manager
 rally_point=map.nearest_road_point(global_position)
 marker.global_position=rally_point
 for i in range(2):
  var a=Assistant.new()
  a.post=self
  a.index=i
  add_child(a)
  a.global_position=global_position+Vector2(-18+i*36,0)
  assistants.append(a)
func set_range_visible(value:bool) -> void:
 show_range=value
 marker.visible=value
 queue_redraw()
func try_move_rally(point:Vector2) -> bool:
 var snapped:Vector2=map.nearest_road_point(point)
 if point.distance_to(snapped)>28 or global_position.distance_to(snapped)>teaching_range:
  return false
 rally_point=snapped
 marker.global_position=rally_point
 for a in assistants: a.return_home()
 queue_redraw()
 return true
func _draw() -> void:
 if show_range:
  draw_circle(Vector2.ZERO,teaching_range,Color(0.4,0.75,1,0.08))
  draw_arc(Vector2.ZERO,teaching_range,0,TAU,96,Color(0.7,0.9,1,0.6),2)
  draw_arc(to_local(rally_point),work_radius,0,TAU,64,Color(1,0.8,0.3,0.7),2)
func _process(delta:float) -> void:
 animation_time+=delta
 point_remaining=maxf(0,point_remaining-delta)
 sprite.texture=point_frames[clampi(int((0.3-point_remaining)*10),0,2)] if point_remaining>0 else idle_frames[int(animation_time*4)%4]
 marker.texture=marker_frames[int(animation_time*5)%5]
func _exit_tree() -> void:
 for a in assistants:
  if is_instance_valid(a): a.release_student()


func point_at(point:Vector2)->void:
 var vector=point-global_position
 var sector=posmod(int(round(vector.angle()/(PI/4))),8)
 var direction=["right","down_right","down","down_left","left","up_left","up","up_right"][sector]
 point_direction=direction
 point_frames=preload("res://scripts/building_frames.gd").pointing(direction)
 point_remaining=0.3
 sprite.texture=point_frames[0]
