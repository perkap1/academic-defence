extends Node2D
const UnitLayout=preload("res://scripts/unit_layout.gd")
var post
var index := 0
var state := "return"
var target
var elapsed := 0.0
var knowledge_accumulator := 0.0
var cooldown := 0.0
var movement_speed := 150.0
var animation_time := 0.0
var frames := {}
var facing := Vector2(1,0)
var sprite := Sprite2D.new()
var teaching_effect := Sprite2D.new()
var effect_frames := []
func _ready() -> void:
 UnitLayout.apply_scale(self)
 sprite.position=Vector2(0,-41)
 add_child(sprite)
 for kind in ["idle","walk","teach"]:
  frames[kind]={}
  for direction in ["front","side","back"]:
   frames[kind][direction]=[]
   for i in range(2 if kind=="idle" else 4):
    frames[kind][direction].append(load("res://assets/assistant/%s_%s_%d.png" % [kind,direction,i]))
 for i in range(5): effect_frames.append(load("res://assets/assistant/teaching_%d.png" % i))
 teaching_effect.visible=false
 teaching_effect.scale=Vector2(0.65,0.65)
 add_child(teaching_effect)
 animate(0,"idle")
func home_position() -> Vector2:
 return post.rally_point+Vector2(-23 if index==0 else 23,8)
func release_student() -> void:
 if is_instance_valid(target): target.release_teacher(self)
 target=null
 teaching_effect.visible=false
func return_home() -> void:
 release_student()
 state="return"
 cooldown=0.8
 elapsed=0.0
 knowledge_accumulator=0.0
func student_completed(student) -> void:
 if target==student: return_home()
func _exit_tree() -> void: release_student()
func animate(delta:float,kind:String) -> void:
 animation_time+=delta
 var direction:String="front" if facing.y>0 else "back"
 if absf(facing.x)>absf(facing.y)*0.8: direction="side"
 sprite.flip_h=direction=="side" and facing.x>0
 var list:Array=frames[kind][direction]
 sprite.texture=list[int(animation_time*(7 if kind=="walk" else 5))%list.size()]
func move_to(point:Vector2,delta:float) -> bool:
 var vector:Vector2=point-global_position
 if vector.length()>0.1: facing=vector
 global_position=global_position.move_toward(point,movement_speed*delta)
 animate(delta,"walk")
 return global_position.distance_to(point)<1
func valid_target() -> bool:
 return is_instance_valid(target) and target.is_targetable() and target.teacher==self and target.global_position.distance_to(post.rally_point)<=post.work_radius+45 and target.global_position.distance_to(post.global_position)<=post.teaching_range
func _process(delta:float) -> void:
 if not is_instance_valid(post) or post.game==null: return
 if post.game.finished:
  return_home()
  return
 cooldown=maxf(0,cooldown-delta)
 if state=="return":
  if move_to(home_position(),delta): state="idle"
  return
 if state=="idle":
  animate(delta,"idle")
  if cooldown>0: return
  # Route order makes reservation deterministic and exclusive across all posts.
  for student in post.map.get_students():
   if not student.is_targetable() or student.global_position.distance_to(post.rally_point)>post.work_radius or student.global_position.distance_to(post.global_position)>post.teaching_range: continue
   if student.reserve_teacher(self):
    target=student
    state="approach"
    post.point_at(student.global_position)
    return
  return
 if not valid_target():
  return_home()
  return
 if state=="approach":
  var side:float=-1 if global_position.x<=target.global_position.x else 1
  var meeting:Vector2=target.global_position+Vector2(side*UnitLayout.MEETING_GAP,0)
  if move_to(meeting,delta):
   target.assistant_hold=true
   state="teach"
   elapsed=0.0
   knowledge_accumulator=0.0
   teaching_effect.visible=true
  return
 if state=="teach":
  facing=target.global_position-global_position
  target.face_teacher(global_position)
  animate(delta,"teach")
  teaching_effect.global_position=(global_position+target.global_position)*0.5+Vector2(0,-67*UnitLayout.SCALE)
  teaching_effect.texture=effect_frames[int(animation_time*7)%5]
  var teaching_time:float=minf(delta,3.0-elapsed)
  elapsed+=teaching_time
  knowledge_accumulator+=teaching_time*5.0
  var amount:int=int(floor(knowledge_accumulator+0.00001))
  if amount>0:
   knowledge_accumulator-=amount
   target.teach(amount)
  if state!="teach": return
  if not valid_target() or elapsed>=3.0: return_home()
