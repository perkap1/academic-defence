extends RefCounted
const SCALE:=0.70
const MAX_LANE:=24.0
const MEETING_GAP:=34.0*SCALE
static var lane_rng:=RandomNumberGenerator.new()
static var initialized:=false
static func apply_scale(unit:Node2D)->void:
 unit.scale=Vector2.ONE*SCALE
 unit.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
static func choose_lane()->float:
 # Separate RNG preserves the existing PE mix and random letter sequence.
 if not initialized:
  lane_rng.randomize()
  initialized=true
 return lane_rng.randf_range(-MAX_LANE,MAX_LANE)
static func tangent(curve:Curve2D,distance:float)->Vector2:
 var length=curve.get_baked_length()
 return (curve.sample_baked(minf(length,distance+8))-curve.sample_baked(maxf(0,distance-8))).normalized()
static func width_factor(curve:Curve2D,distance:float)->float:
 var center=curve.sample_baked(distance)
 # Both current maps enter a gate/bridge on the left and exit a bridge on right.
 var bridges=smoothstep(70.0,190.0,center.x)*(1.0-smoothstep(1450.0,1570.0,center.x))
 var before=tangent(curve,maxf(0,distance-75))
 var after=tangent(curve,minf(curve.get_baked_length(),distance+75))
 var bend=clampf(pow((1.0+before.dot(after))*0.5,3.0),0.10,1.0)
 return bridges*bend
static func lane_position(curve:Curve2D,distance:float,lane:float)->Vector2:
 var direction=tangent(curve,distance)
 var normal=Vector2(-direction.y,direction.x)
 return curve.sample_baked(distance)+normal*clampf(lane,-MAX_LANE,MAX_LANE)*width_factor(curve,distance)
