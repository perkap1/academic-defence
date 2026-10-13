extends "res://scripts/student.gd"
var hit_time:=0.0
var defeat_time:=0.0
var defeated:=false
func configure(_kind:String="pilot",_sex:String="girl")->void:
 super.configure("normal","girl")
 student_type="pilot"
 speed=102.0
 base_speed=speed
func _ready()->void:
 configure()
 super._ready()
 frames=preload("res://scripts/pilot_frames.gd").create()
 sprite.scale=Vector2.ONE*0.55
 sprite.offset=Vector2(-120,-245)
 sprite.position=Vector2(0,-40)
 sprite.texture=frames[direction][0]
 bar.max_value=150
 bar.position.y=-165
 z_index=3
func can_receive_attack(kind:String)->bool:
 return not done and kind=="book"
func receive_attack(amount:int,kind:String)->void:
 if not can_receive_attack(kind) or amount<=0:return
 knowledge=mini(150,knowledge+amount)
 bar.value=knowledge
 hit_time=0.24
 if knowledge==150:complete(true)
func teach(_amount:int)->void:pass # Unsourced / ground Knowledge cannot affect flight.
func apply_slow(_duration:float=2.0,_strength:float=0.30,_source:String="other")->void:pass
func reserve_teacher(_candidate)->bool:return false
func show_wet_hit()->void:pass
func animation_frame()->int:
 if hit_time>0:return 4+mini(1,int((0.24-hit_time)*8.34))
 return int(animation_time*6)%4
func _process(delta:float)->void:
 if defeated:
  defeat_time+=delta
  sprite.texture=frames[direction][6+mini(2,int(defeat_time*7.5))]
  if defeat_time>=0.4:queue_free()
  return
 hit_time=maxf(0,hit_time-delta)
 super._process(delta)
func complete(graduated:bool)->void:
 if done:return
 if not graduated:
  super.complete(false);return
 done=true
 defeated=true
 bar.hide()
 remove_from_group("students")
 sprite.texture=frames[direction][6]
 # Detach so routing/targeting counts resolve immediately; visual defeat remains.
 var level=get_parent().get_parent()
 var world=global_position
 resolved.emit(self,true)
 reparent(level.effects)
 global_position=world
