extends "res://scripts/student.gd"
const EATING_DURATION:=2.0
var snack_break_used:=false
var eating_remaining:=0.0
var teaching_points:=0
var heal_remaining:=0.0
func configure(_kind:String="snack",_sex:String="boy")->void:
 super.configure("normal","boy")
 student_type="snack"
 base_speed=59.5
 speed=base_speed
func _ready()->void:
 configure()
 super._ready()
 frames=preload("res://scripts/snack_frames.gd").create()
 sprite.offset=Vector2(-90,-210)
 sprite.scale=Vector2.ONE*0.57
 sprite.texture=frames[direction][2]
 bar.position=Vector2(-40,-122)
func is_eating()->bool: return eating_remaining>0
func is_targetable()->bool: return not done and not is_eating()
func teach(amount:int)->void:
 if not is_targetable() or amount<=0:return
 teaching_points=mini(400,teaching_points+amount)
 knowledge=int(teaching_points/4.0)
 bar.value=teaching_points/4.0
 if not snack_break_used and teaching_points>=200:
  snack_break_used=true
  eating_remaining=EATING_DURATION
  animation_time=0
  slow_remaining=0
  slow_strength=0
  speed=base_speed
  slow_indicator.hide()
  if is_instance_valid(teacher):teacher.student_completed(self)
  teacher=null
  assistant_hold=false
  sprite.modulate=Color.WHITE
  sprite.texture=frames[direction][6]
  queue_redraw()
  return
 if teaching_points>=400:complete(true)
func apply_slow(duration:float=2.0,strength:float=0.30)->void:
 if is_targetable():super.apply_slow(duration,strength)
func show_wet_hit()->void:
 if is_targetable():super.show_wet_hit()
func reserve_teacher(candidate)->bool:
 return super.reserve_teacher(candidate) if is_targetable() else false
func complete(graduated:bool)->void:
 if is_eating():return
 super.complete(graduated)
func animation_frame()->int:
 if is_eating():return 6+int(animation_time*4)%4
 if assistant_hold:return int(animation_time*2)%2
 return 2+int(animation_time*4)%4
func _process(delta:float)->void:
 if done:return
 if is_eating():
  var elapsed=minf(delta,eating_remaining)
  animation_time+=elapsed
  eating_remaining=maxf(0,eating_remaining-elapsed)
  sprite.texture=frames[direction][6+int(animation_time*4)%4]
  if eating_remaining>0.000001:return
  eating_remaining=0
  teaching_points=100
  knowledge=25
  bar.value=25
  heal_remaining=0.5
  animation_time=0
  sprite.texture=frames[direction][2]
  queue_redraw()
  delta-=elapsed
  if delta<=0:return
 var was_healing=heal_remaining>0
 heal_remaining=maxf(0,heal_remaining-delta)
 if was_healing:queue_redraw()
 super._process(delta)
func _draw()->void:
 super._draw()
 if is_eating():
  draw_rect(Rect2(-8,-109,5,12),Color("ffd778"))
  draw_rect(Rect2(3,-109,5,12),Color("ffd778"))
 elif heal_remaining>0:
  draw_rect(Rect2(-2,-109,4,16),Color("8de477"))
  draw_rect(Rect2(-8,-103,16,4),Color("8de477"))
