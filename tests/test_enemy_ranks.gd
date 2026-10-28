extends "res://tests/test_pe_teacher.gd"

func run():
 var first=load("res://scenes/main.tscn").instantiate();root.add_child(first);first.process_mode=Node.PROCESS_MODE_DISABLED
 check(first.waves.has_method("get_next_wave_ranks"),"Wave plans carry cached elite and boss replacements")
 if failures:first.free();finish();return
 first.free()
 for id in range(1,6):
  var main=load("res://scenes/%s.tscn"%("main" if id==1 else "main_map%d"%id)).instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
  for w in range(1,main.waves.counts.size()+1):
   main.waves.wave=w-1;main.waves.active=false
   var plan:Array=main.waves.get_spawn_plan(w)
   var state:int=main.waves.variant_rng.state
   check(plan==main.waves.get_spawn_plan(w) and state==main.waves.variant_rng.state,"Preview never rerolls rank, type, sex or entry")
   check(plan.size()==main.waves.counts[w-1],"Rank replacement preserves wave total")
   var ranked=[]
   for i in range(plan.size()):
    check(plan[i].kind==main.waves.get_spawn_kind(i,w) and plan[i].route==main.waves.get_spawn_route(i,w),"Replacement preserves existing type mix and route")
    if plan[i].get("rank","")!="":ranked.append(plan[i])
   var final:bool=w==main.waves.counts.size()
   check(ranked.size()==(1 if final else (2 if w==9 else (1 if w%3==0 else 0))),"Every third wave, two elites at nine, final boss priority")
   for record in ranked:
    check(record.rank==("boss" if final else "elite"),"Final wave gets boss, other third waves elite")
    check(is_equal_approx(record.health_multiplier,5.0 if final else 1.5+0.5*int(w/3)),"Exact requested multiplier")
    if final:check(record.kind==["normal","pe","bookworm","snack","pilot"][id-1],"Temporary boss follows the selected map archetype")
   main.update_ui()
   var ranks:Dictionary=main.waves.get_next_wave_ranks()
   var preview_count:=0
   for entry_records in ranks.values():
    if entry_records is Array:preview_count+=entry_records.size()
   check(preview_count==ranked.size(),"Preview retains every ranked unit including shared entrances")
   for entry in main.wave_preview.icons:
    check(main.wave_preview.icons[entry].dangerous==ranks.has(entry),"Dark-red warning only at ranked pupil's actual entrance")
    check((main.wave_preview.icons[entry].material is ShaderMaterial)==ranks.has(entry),"Ranked warning actually applies the dark-red palette")
    main.wave_preview.show_entry(entry)
    check(main.wave_preview.rank_label.visible==ranks.has(entry),"Hover includes rank only on its own route")
    if ranks.has(entry):
     check(main.wave_preview.rank_label.text.count("ELITE:")+main.wave_preview.rank_label.text.count("BOSS:")==ranks[entry].size(),"Hover shows both elites when they share an entrance")
   main.waves.start_wave();main.waves._process(10000)
   check(main.waves.students.size()==plan.size(),"Actual spawn stream retains full original count")
   for i in range(plan.size()):
    var unit=main.waves.students[i]
    check(unit.enemy_rank==plan[i].get("rank","") and is_equal_approx(unit.health_multiplier,plan[i].get("health_multiplier",1.0)),"Actual rank and multiplier match cached preview")
    check(unit.get_parent()==main.map.get_routes()[plan[i].route],"Rank does not move entrances")
    unit.free()
   main.waves.students.clear();main.waves.active=false
  main.free()
 var main=load("res://scenes/main_map3.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var base={"normal":100.0,"pe":90.0,"bookworm":90.0,"snack":400.0,"clown":120.0,"pilot":150.0}
 for kind in base:
  for multiplier in [2.0,2.5,3.0,3.5,5.0]:
   var unit=pupil(main,kind,main.map.route,400)
   var reward:int=unit.base_reward;var speed:float=unit.base_speed;var location:Vector2=unit.global_position
   unit.set_enemy_rank("boss" if multiplier==5 else "elite",multiplier)
   check(unit.base_reward==reward and unit.base_speed==speed and unit.global_position==location,"Rank leaves reward, movement and origin unchanged")
   var capacity:float=base[kind]*multiplier
   check(unit.get_heal_capacity()==capacity,"Actual health and healing capacity scale for "+kind)
   check(unit.rank_label.text==("BOSS" if multiplier==5 else "E"),"Rank marker sits above the health bar")
   check(unit.rank_label.get_parent()==unit.bar and unit.rank_label.position.y<0,"Marker shares stable health-bar origin")
   if kind=="bookworm":
    for j in range(3):unit.receive_attack(1,"book")
    check(unit.books==0,"Bookworm keeps exactly three shields")
   if kind=="snack":unit.snack_break_used=true
   var amount:int=int(capacity*.6);unit.receive_attack(amount,"book")
   check(not unit.done,"Ranked pupil survives ordinary damage below scaled threshold")
   unit.receive_confetti_heal(.25)
   var actual:float=unit.teaching_points if kind=="snack" else unit.knowledge
   check(is_equal_approx(actual,maxf(0,amount-capacity*.25)),"Confetti restores exactly25percent of ranked maximum")
   check(is_equal_approx(unit.bar.value,actual/4.0 if kind=="snack" else actual),"Bar follows scaled health including Snack normalization")
   var resolved=[0];unit.resolved.connect(func(_u,_g):resolved[0]+=1)
   unit.receive_attack(int(capacity)*2,"book");unit.receive_attack(int(capacity)*2,"book")
   check(unit.done and resolved[0]==1,"Ranked graduation resolves exactly once")
   check(not unit.receive_confetti_heal(.25),"Confetti cannot revive a graduated ranked pupil")
   unit.free()
 var snack=pupil(main,"snack",main.map.route,400);snack.set_enemy_rank("elite",2.5)
 snack.receive_attack(500,"book");check(snack.is_eating(),"Snack break begins at half of ranked maximum")
 snack.receive_confetti_heal(.25);snack._process(2)
 check(snack.teaching_points==0 and snack.snack_break_used,"Ranked Snack break and full25percent confetti coexist")
 snack.free()
 var boss=pupil(main,"normal",main.map.route,400);boss.set_enemy_rank("boss",5);boss.teach(300)
 var clown=pupil(main,"clown",main.map.route,400);clown.set_enemy_rank("elite",2);clown.teach(180)
 clown.begin_cast();clown.heal_pulse()
 check(boss.knowledge==175 and clown.knowledge==120 and clown.heal_percent==.25,"Live clown pulse heals boss and itself by25percent without rank exception")
 boss.free();clown.free()
 var at:float=main.map.lower_route.curve.get_closest_offset(Vector2(920,440))
 var hidden=pupil(main,"normal",main.map.lower_route,at);hidden.set_enemy_rank("boss",5)
 check(not hidden.visible and not hidden.can_receive_attack("book"),"Ranked boss still hides fully under bridge")
 check(hidden.rank_material.get_shader_parameter("clip_bridge")==true and hidden.bar.material==main.map.get_bridge_clip_material(),"Clothing palette and bar preserve tunnel mask")
 check(hidden.rank_label.use_parent_material and not hidden.rank_label.is_visible_in_tree(),"Rank marker does not reveal a hidden enemy")
 var tower=load("res://scenes/pe_teacher.tscn").instantiate();main.map.towers.add_child(tower);tower.configure(main.map,main.game)
 var ball=tower.launch_ball(main.map.lower_route,at);ball.advance(ball.FLIGHT_TIME)
 check(hidden.knowledge==50,"Medicine ball still hits a ranked enemy under the bridge")
 hidden.receive_confetti_heal(.25);check(hidden.knowledge==0,"Hidden boss still receives full25percent healing")
 hidden.free();main.free()
 var exam=load("res://scenes/main_map5.tscn").instantiate();root.add_child(exam);exam.process_mode=Node.PROCESS_MODE_DISABLED
 var seen={}
 for seed_value in range(40):
  exam.waves.variant_rng.seed=seed_value;exam.waves.planned_waves.erase(6)
  for record in exam.waves.get_spawn_plan(6):
   if record.get("rank","")=="elite":seen[record.kind]=true
 check(seen.size()>=4,"Elite choice varies across available enemy types")
 exam.free()
 var combinations={}
 for seed_value in range(200):
  var sample=[{"kind":"normal","route":0},{"kind":"normal","route":0},{"kind":"normal","route":1},{"kind":"pe","route":0},{"kind":"pe","route":1},{"kind":"pe","route":1}]
  var rng=RandomNumberGenerator.new();rng.seed=seed_value
  preload("res://scripts/enemy_ranks.gd").decorate(sample,9,22,5,rng)
  var chosen=[]
  for record in sample:
   if record.has("rank"):chosen.append(record)
  check(chosen.size()==2,"Two different spawn records become elite at wave nine")
  combinations[str(chosen[0].kind==chosen[1].kind)+str(chosen[0].route==chosen[1].route)]=true
 check(combinations.size()==4,"Random pair permits same/different types and same/different entrances")
 finish()
func finish():
 print("ENEMY RANKS: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
