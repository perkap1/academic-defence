extends "res://scripts/student.gd"
const ClownFrames=preload("res://scripts/class_clown_frames.gd")
const CAST_DURATION:=0.75
const PULSE_TIME:=0.30
@export var heal_radius:=180.0
@export var heal_interval:=4.0
@export var heal_percent:=0.25
var heal_clock:=0.0
var casting:=false
var cast_elapsed:=0.0
var pulse_fired:=false
var pulses_fired:=0
var hit_time:=0.0
var defeated:=false
var defeat_time:=0.0
func configure(_kind:String="clown",_sex:String="boy")->void:
 super.configure("normal","boy")
 student_type="clown";base_speed=85.0;speed=base_speed;base_reward=10
func _ready()->void:
 configure();super._ready()
 frames=ClownFrames.create();sprite.scale=Vector2.ONE*0.36;sprite.offset=Vector2(-140,-285)
 sprite.texture=frames[direction][animation_frame()];bar.max_value=120
 sync_art()
 bar.position=Vector2(-40,-106);bar.size.x=56
 update_lane_position()
func get_heal_capacity()->float:return 120.0
func animation_frame()->int:
 if defeated:return 13+mini(4,int(defeat_time/0.85*5))
 if casting:return 6+mini(4,int(cast_elapsed/CAST_DURATION*5))
 if hit_time>0:return 11+mini(1,int((0.20-hit_time)*10))
 if assistant_hold:return int(animation_time*2)%2
 return 2+int(animation_time*8)%4
func teach(amount:int)->void:
 if not is_targetable() or amount<=0:return
 knowledge=minf(120,knowledge+amount);bar.value=knowledge;hit_time=0.20
 if knowledge>=120:complete(true)
func sync_art()->void:
 var frame:=animation_frame()
 sprite.texture=frames[direction][frame]
 # Source rows have different drawing scales; normalize each animation around its fixed wheel pivot.
 sprite.scale=Vector2.ONE*1.25*(0.30 if frame<2 else (0.28 if frame>=11 else 0.36))
 sprite.offset=Vector2(-200,-310) if defeated else Vector2(-140,-285)
func begin_cast()->void:
 casting=true;cast_elapsed=0;pulse_fired=false;heal_clock=0;sync_art()
func heal_pulse()->void:
 if done or pulse_fired:return
 pulse_fired=true;pulses_fired+=1
 var level=get_parent().get_parent()
 var effect=AttackEffect.new();effect.configure("confetti",6,0.55);effect.frames=ClownFrames.confetti()
 level.effects.add_child(effect);effect.global_position=global_position+Vector2(0,-30)
 effect.sprite.centered=false;effect.sprite.offset=Vector2(-300,-300);effect.sprite.scale=Vector2.ONE*(heal_radius*2/500.0)
 for unit in level.get_students():
  if is_instance_valid(unit) and not unit.done and unit.global_position.distance_to(global_position)<=heal_radius:
   unit.receive_confetti_heal(heal_percent)
func _process(delta:float)->void:
 if defeated:
  defeat_time+=delta;sync_art()
  if defeat_time>=0.85:queue_free()
  return
 if done:return
 var remaining:=delta
 while remaining>0.000001 and not done:
  var until_event:float=(PULSE_TIME-cast_elapsed if not pulse_fired else CAST_DURATION-cast_elapsed) if casting else heal_interval-heal_clock
  var step:=minf(remaining,maxf(0.0,until_event))
  heal_clock+=step;hit_time=maxf(0,hit_time-step)
  if casting:cast_elapsed+=step
  var held:=assistant_hold
  if casting:assistant_hold=true
  super._process(step)
  assistant_hold=held
  remaining-=step
  if done:break
  if casting:
   if not pulse_fired and cast_elapsed>=PULSE_TIME-0.000001:heal_pulse()
   if cast_elapsed>=CAST_DURATION-0.000001:casting=false
  elif heal_clock>=heal_interval-0.000001:begin_cast()
  sync_art()
 if delta<=0 and not done:super._process(0);sync_art()
func predict_position(seconds:float)->Vector2:
 if assistant_hold or not get_parent() is Path2D:return global_position
 var remaining:=seconds;var elapsed:=0.0;var travel:=0.0
 var clock:=heal_clock
 var stop_left:float=CAST_DURATION-cast_elapsed if casting else 0.0
 while remaining>0.000001:
  if stop_left>0:
   var wait:=minf(remaining,stop_left)
   remaining-=wait;elapsed+=wait;clock+=wait;stop_left-=wait
  else:
   var step:=minf(remaining,maxf(0.0,heal_interval-clock))
   travel+=base_speed*(step-minf(step,maxf(0,slow_remaining-elapsed))*slow_strength)
   remaining-=step;elapsed+=step;clock+=step
   if clock>=heal_interval-0.000001:clock=0;stop_left=CAST_DURATION
 var path:Path2D=get_parent()
 return path.to_global(UnitLayout.lane_position(path.curve,minf(path.curve.get_baked_length(),progress+travel),lane_offset))
func complete(graduated:bool)->void:
 if done:return
 if not graduated:super.complete(false);return
 done=true;defeated=true;casting=false
 if is_instance_valid(teacher):teacher.student_completed(self)
 teacher=null;assistant_hold=false;bar.hide();slow_indicator.hide();remove_from_group("students")
 sync_art()
 var level=get_parent().get_parent();var world=global_position
 resolved.emit(self,true)
 reparent(level.effects);global_position=world
