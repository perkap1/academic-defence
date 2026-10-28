extends RefCounted
const BOSS_TYPES:=["normal","pe","bookworm","snack","pilot"]

static func decorate(plan:Array,wave_id:int,last_wave:int,level_id:int,rng:RandomNumberGenerator)->void:
 if plan.is_empty() or (wave_id!=last_wave and wave_id%3!=0):return
 var by_type:Dictionary={}
 for i in range(plan.size()):
  var kind:String=plan[i].kind
  if not by_type.has(kind):by_type[kind]=[]
  by_type[kind].append(i)
 var boss:=wave_id==last_wave
 var count:int=1 if boss or wave_id!=9 else mini(2,plan.size())
 for selection in range(count):
  var kinds:Array=by_type.keys()
  var kind:String=BOSS_TYPES[level_id-1] if boss and by_type.has(BOSS_TYPES[level_id-1]) else kinds[rng.randi_range(0,kinds.size()-1)]
  var choices:Array=by_type[kind]
  var index:int=choices[rng.randi_range(0,choices.size()-1)]
  plan[index]["rank"]="boss" if boss else "elite"
  plan[index]["health_multiplier"]=5.0 if boss else 1.5+0.5*int(wave_id/3)
  # Draw again from remaining pupils: the same type and entry may be chosen twice.
  choices.erase(index)
  if choices.is_empty():by_type.erase(kind)
