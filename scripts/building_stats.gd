extends RefCounted
# One instance per building; projectiles retain only this record, never the tower.
var total: Dictionary = {}
var stages: Array[Dictionary] = [{}]
var stage_name := "Level 1"
var upgrade_events: Array[Dictionary] = []
signal changed
func current() -> Dictionary: return stages.back()
func add(key: String, value: float = 1.0) -> void:
 if value <= 0: return
 total[key] = float(total.get(key,0))+value
 current()[key] = float(current().get(key,0))+value
 changed.emit()
func upgrade(name: String) -> void:
 stage_name=name
 upgrade_events.append({"from":stages.size(),"to":name,"at_msec":Time.get_ticks_msec()})
 stages.append({})
 changed.emit()
func teach(student, amount: int) -> bool:
 if not is_instance_valid(student) or not student.is_targetable() or amount<=0: return false
 var before: float = student.teaching_points if student.student_type=="snack" else student.knowledge
 var books: int = student.books if student.student_type=="bookworm" else 0
 student.teach(amount)
 var after: float = student.teaching_points if student.student_type=="snack" else student.knowledge
 add("knowledge",maxf(0,after-before))
 if student.student_type=="bookworm":add("shields",books-student.books)
 if student.done and after>before:add("graduated")
 return true
func rows(kind: String, branch: String = "") -> Array:
 if kind=="economy":
  if branch=="scholarship":return [["kp","KP generert"],["rewarded","Elever belønnet"],["waves","Waves med inntekt"]]
  return [["kp","KP generert"],["waves","Waves med inntekt"]]
 if kind=="assistant":return [["knowledge","Kunnskap gitt"],["graduated","Elever uteksaminert"],["stopped","Elever stoppet"],["time","Undervisningstid (s)"]]
 if kind=="blackboard":return [["knowledge","Kunnskap gitt"],["graduated","Elever uteksaminert"],["hits","Elever truffet"],["slows","Slow påført"],["shots","Prosjektiler kastet"]]
 return [["knowledge","Kunnskap gitt"],["graduated","Elever uteksaminert"],["shots","Bøker kastet"],["hits","Treffsikre kast"],["shields","Bokskjold fjernet"]]

func record_income_wave(wave_id: int) -> void:
 if current().get("_income_wave",-1) == wave_id: return
 current()["_income_wave"] = wave_id
 current()["waves"] = current().get("waves",0)+1
 if total.get("_income_wave",-1) != wave_id:
  total["_income_wave"] = wave_id
  total["waves"] = total.get("waves",0)+1
 changed.emit()
