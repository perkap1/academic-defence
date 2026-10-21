extends Node2D
const Art=preload("res://scripts/pe_teacher_frames.gd")
const Layout=preload("res://scripts/unit_layout.gd")
const FLIGHT_TIME:=0.55
const ROLL_SPEED:=300.0
const BASE_RADIUS:=27.0
const BURST_TIME:=0.36
var map
var path:Path2D
var progress:=0.0
var roll_direction:=1.0
var distance_travelled:=0.0
var roll_limit:=0.0
var size_factor:=1.0
var hit_radius:=27.0
var knowledge:=0
var source_stats
var source_stage:=0
var hit_ids:Dictionary={}
var hit_count:=0
var state:="flight"
var elapsed:=0.0
var origin:=Vector2.ZERO
var landing:=Vector2.ZERO
var ball:=Sprite2D.new()
var trail:=Sprite2D.new()
var dust:=Sprite2D.new()
var speed_frames:=[]
var dust_frames:=[]

func configure(level_map,route:Path2D,at:float,amount:int,distance:float,size:float,record)->void:
 map=level_map;path=route;progress=clampf(at,0,path.curve.get_baked_length())
 knowledge=amount;roll_limit=distance;size_factor=size;hit_radius=BASE_RADIUS*size
 source_stats=record;source_stage=record.stages.size()-1
 landing=path.to_global(path.curve.sample_baked(progress))
func _ready()->void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 speed_frames=Art.speed();dust_frames=Art.dust()
 ball.texture=Art.ball();ball.scale=Vector2.ONE*0.17*size_factor
 trail.texture=speed_frames[0];trail.centered=false;trail.offset=Vector2(-420,-160);trail.scale=Vector2.ONE*0.12*size_factor
 dust.texture=dust_frames[0];dust.centered=false;dust.offset=Vector2(-200,-260);dust.scale=Vector2.ONE*0.13*size_factor
 add_child(dust);add_child(trail);add_child(ball);dust.hide()
func launch_from(point:Vector2,ground_origin:Vector2=Vector2.INF)->void:
 origin=point;global_position=point
 # Choose the road direction most aligned with the throw across the ground.
 # The raised hand/visual flight arc must not reverse a vertical-road throw.
 var throw_vector:=landing-(point if ground_origin==Vector2.INF else ground_origin)
 var tangent:Vector2=path.global_transform.basis_xform(Layout.tangent(path.curve,progress)).normalized()
 roll_direction=-1.0 if throw_vector.dot(tangent)<-0.0001 else 1.0
 update_visual()
func _process(delta:float)->void:advance(delta)
func advance(delta:float)->void:
 if is_queued_for_deletion():return
 if not is_instance_valid(path) or not is_instance_valid(map) or map.get_parent().game.finished:
  set_process(false);queue_free();return
 var remaining:=delta
 if state=="flight":
  var step:=minf(remaining,FLIGHT_TIME-elapsed);elapsed+=step;remaining-=step
  var t:=clampf(elapsed/FLIGHT_TIME,0,1)
  global_position=origin.lerp(landing,t)+Vector2(0,-95*4*t*(1-t))
  if elapsed>=FLIGHT_TIME:
   state="rolling";elapsed=0;global_position=landing
   hit_segment(progress,progress)
 if state=="rolling":
  var before:=progress
  var available:float=path.curve.get_baked_length()-progress if roll_direction>0 else progress
  var travel:=minf(remaining*ROLL_SPEED,minf(roll_limit-distance_travelled,available))
  progress=clampf(progress+travel*roll_direction,0,path.curve.get_baked_length());distance_travelled+=travel;elapsed+=remaining
  hit_segment(before,progress)
  global_position=path.to_global(path.curve.sample_baked(progress))
  if distance_travelled>=roll_limit-0.001 or available-travel<=0.001:
   state="burst";elapsed=0
 elif state=="burst":
  elapsed+=remaining
  if elapsed>=BURST_TIME:set_process(false);queue_free();return
 update_visual();queue_redraw()

func hit_segment(start:float,end:float)->void:
 # Sample the curve rather than sweeping one straight chord across a bend.
 var samples:=maxi(1,ceili(absf(end-start)/8.0))
 for unit in map.get_students():
  if not is_instance_valid(unit) or hit_ids.has(unit.get_instance_id()) or not unit.can_receive_attack("medicine_ball"):continue
  var route:Path2D=unit.get_parent()
  var center:Vector2=route.to_global(route.curve.sample_baked(unit.progress))
  for i in range(samples+1):
   var offset:=lerpf(start,end,float(i)/samples)
   var point:=path.to_global(path.curve.sample_baked(offset))
   if route!=path:
    # Different entrances may share outgoing segments, but crossing or nearby
    # independent roads must never borrow one another's collisions.
    var other_at:=route.curve.get_closest_offset(route.to_local(point))
    var other_point:=route.to_global(route.curve.sample_baked(other_at))
    if other_point.distance_to(point)>3.0 or Layout.tangent(path.curve,offset).dot(Layout.tangent(route.curve,other_at))<0.95:continue
   if center.distance_to(point)<=hit_radius and unit.global_position.distance_to(point)<=hit_radius+8:
    if source_stats.teach(unit,knowledge,"medicine_ball",source_stage):
     hit_ids[unit.get_instance_id()]=true;hit_count+=1
     source_stats.add("hits",1,source_stage);source_stats.record_max("max_hits",hit_count,source_stage)
    break

func update_visual()->void:
 trail.visible=state=="flight";dust.visible=state!="flight";ball.visible=state!="burst"
 var tangent:Vector2=landing-origin+Vector2(0,-380+760*clampf(elapsed/FLIGHT_TIME,0,1)) if state=="flight" else Layout.tangent(path.curve,progress)*roll_direction
 trail.rotation=tangent.angle()
 if state=="flight":
  trail.texture=speed_frames[mini(2,int(elapsed/FLIGHT_TIME*3))]
  ball.position=Vector2.ZERO;ball.rotation=elapsed*7
 else:
  ball.position=Vector2(0,-hit_radius*0.75)
  ball.rotation=roll_direction*distance_travelled/(BASE_RADIUS*size_factor)
  dust.texture=dust_frames[clampi(int(elapsed/BURST_TIME*4),0,3) if state=="burst" else int(elapsed*10)%4]
  dust.scale=Vector2.ONE*(0.22 if state=="burst" else 0.13)*size_factor
  dust.modulate.a=1.0-clampf(elapsed/BURST_TIME,0,1) if state=="burst" else 0.8
 # Reuse the exact world-space roof mask that progressively hides pupils.
 # The same material clips ball, dust and ground shadow, without stopping hits.
 var cover:ShaderMaterial=null
 if state!="flight" and map.has_method("get_bridge_clip_material") and path==map.lower_route:
  cover=map.get_bridge_clip_material()
 material=cover;ball.material=cover;dust.material=cover
func _draw()->void:
 if state!="burst":
  draw_set_transform(Vector2.ZERO,0,Vector2(1,0.3))
  draw_circle(Vector2.ZERO,hit_radius*0.7,Color(0.02,0.06,0.06,0.25))
