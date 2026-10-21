extends "res://scripts/book_tower.gd"
const Art=preload("res://scripts/pe_teacher_frames.gd")
const Ball=preload("res://scripts/medicine_ball.gd")
const BUILD_COST:=150
const UPGRADE_COSTS:=[180,300]
const INTERVALS:=[3.8,3.7,3.6]
const KNOWLEDGE:=[50,65,80]
const ROLL_DISTANCES:=[240.0,300.0,360.0]
const BALL_SIZES:=[1.0,1.15,1.35]
const WINDUP:=0.6
const ATTACK_DURATION:=0.8
var roll_distance:=240.0
var ball_size:=1.0
var pending_target
var pending_path:Path2D
var pending_progress:=0.0
var release_remaining:=0.0
var actor_materials:Array=[]
var fixed_basket:Sprite2D

func _ready()->void:
 tower_type="pe_teacher";total_invested=BUILD_COST;teaching_range=230.0
 apply_level();frames=Art.create()
 sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 sprite.centered=false;sprite.offset=Vector2(-350,-560)
 sprite.position=Vector2(0,-1.95);sprite.scale=Vector2.ONE*0.247
 base_sprite=Sprite2D.new();add_child(base_sprite);move_child(base_sprite,0)
 base_sprite.centered=false;base_sprite.offset=sprite.offset;base_sprite.position=sprite.position;base_sprite.scale=sprite.scale
 base_sprite.texture=frames[0];base_sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var base_material=ShaderMaterial.new();base_material.shader=Presentation.BASE_SHADER
 base_material.set_shader_parameter("cut_y",-121.0);base_material.set_shader_parameter("upper",false);base_sprite.material=base_material
 fixed_basket=Sprite2D.new();fixed_basket.texture=Art.fixed_basket()
 fixed_basket.centered=false;fixed_basket.offset=sprite.offset;fixed_basket.position=sprite.position;fixed_basket.scale=sprite.scale
 fixed_basket.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(fixed_basket);move_child(fixed_basket,1)
 for i in range(9):actor_materials.append(Art.actor_material(i))
 var badge=preload("res://scripts/book_level_badge.gd").new();badge.name="LevelBadge";badge.z_index=2;badge.scale=Vector2.ONE*0.65;add_child(badge)
 update_sprite(0)

func apply_level()->void:
 fire_interval=INTERVALS[level-1];knowledge_per_hit=KNOWLEDGE[level-1]
 roll_distance=ROLL_DISTANCES[level-1];ball_size=BALL_SIZES[level-1]
func configure(level_map,manager)->void:
 super.configure(level_map,manager)
 fixed_basket.flip_h=sprite.flip_h
func get_upgrade_cost()->int:return 0 if level>=3 else UPGRADE_COSTS[level-1]
func get_display_name()->String:return "PE Teacher Tower"
func upgrade_level()->bool:
 var cost=get_upgrade_cost()
 if cost==0:return false
 total_invested+=cost;level+=1;stats.upgrade("Level %d"%level);apply_level()
 get_node("LevelBadge").queue_redraw();queue_redraw();return true
func get_visual_frame()->int:
 if animation_time>0:return 4+clampi(int((ATTACK_DURATION-animation_time)/0.16),0,4)
 return int(visual_time*2.0)%4
func update_sprite(delta:float)->void:
 visual_time+=delta
 var index:=get_visual_frame()
 sprite.texture=frames[index];sprite.material=actor_materials[index]
 sprite.material.set_shader_parameter("flipped",sprite.flip_h)
 sprite.scale=Vector2.ONE*0.247*(1.23 if index>=4 else 1.0)
 sprite.position=Vector2(0,0.85 if index>=4 else -1.95)
 if is_instance_valid(fixed_basket):fixed_basket.flip_h=sprite.flip_h
func launch_ball(path:Path2D,at:float):
 var ball=Ball.new()
 ball.configure(map,path,at,knowledge_per_hit,roll_distance,ball_size,stats)
 map.projectiles.add_child(ball)
 var side:float=-1 if sprite.flip_h else 1
 var hand:=global_position+Vector2(side*28,-72)
 ball.launch_from(hand,Vector2(hand.x,global_position.y))
 stats.add("shots")
 return ball
func release_ball()->void:
 if not is_instance_valid(pending_path):return
 if is_instance_valid(pending_target) and pending_target.can_receive_attack("pe_teacher"):
  pending_progress=pending_path.curve.get_closest_offset(pending_path.to_local(pending_target.predict_position(Ball.FLIGHT_TIME)))
 launch_ball(pending_path,pending_progress)
 pending_path=null;pending_target=null
func _process(delta:float)->void:
 if game==null or game.finished:return
 cooldown=maxf(0,cooldown-delta);animation_time=maxf(0,animation_time-delta)
 if release_remaining>0:
  release_remaining=maxf(0,release_remaining-delta)
  if release_remaining==0:release_ball()
 update_sprite(delta)
 if cooldown>0:return
 var nearest=null;var closest:=teaching_range
 for unit in map.get_students():
  if not is_instance_valid(unit) or not unit.can_receive_attack("pe_teacher"):continue
  var distance:=global_position.distance_to(unit.global_position)
  if distance<=closest:nearest=unit;closest=distance
 if nearest==null:return
 pending_target=nearest;pending_path=nearest.get_parent()
 pending_progress=nearest.progress
 var road_position:Vector2=pending_path.to_global(pending_path.curve.sample_baked(nearest.progress))
 sprite.flip_h=road_position.x<global_position.x;base_sprite.flip_h=sprite.flip_h
 animation_time=ATTACK_DURATION;release_remaining=WINDUP;cooldown=fire_interval;update_sprite(0)
