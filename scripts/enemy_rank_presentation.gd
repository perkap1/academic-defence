extends RefCounted
const SHADER=preload("res://scripts/enemy_rank.gdshader")
# Tight torso regions in the original, pivot-aligned unit coordinate system.
# Hue selection inside these bounds leaves skin, hair, books and plane intact.
const CLOTHES={
 "normal":Vector4(-26,-31,26,-8),"pe":Vector4(-30,-37,30,-12),
 "bookworm":Vector4(-40,-36,40,-3),"snack":Vector4(-40,-82,40,-15),
 "clown":Vector4(-37,-52,37,-25),"pilot":Vector4(-35,-112,35,-65)
}
static func apply(unit)->void:
 if unit.enemy_rank=="":return
 if unit.rank_material==null:
  unit.rank_material=ShaderMaterial.new();unit.rank_material.shader=SHADER
 unit.rank_material.set_shader_parameter("boss",unit.enemy_rank=="boss")
 unit.rank_material.set_shader_parameter("kind",["normal","pe","bookworm","snack","clown","pilot"].find(unit.student_type))
 unit.rank_material.set_shader_parameter("clothes",CLOTHES.get(unit.student_type,CLOTHES.normal))
 unit.rank_material.set_shader_parameter("actor_scale",unit.global_transform.x.length())
 unit.sprite.material=unit.rank_material
 if not is_instance_valid(unit.rank_label):
  unit.rank_label=Label.new();unit.rank_label.name="EnemyRank"
  unit.rank_label.position=Vector2(0,-23);unit.rank_label.size=Vector2(unit.bar.size.x,21)
  unit.rank_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  unit.rank_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
  unit.rank_label.add_theme_font_size_override("font_size",16)
  unit.rank_label.add_theme_color_override("font_color",Color("fff0c0"))
  unit.rank_label.add_theme_color_override("font_outline_color",Color("57131f"))
  unit.rank_label.add_theme_constant_override("outline_size",4)
  unit.rank_label.use_parent_material=true
  unit.bar.add_child(unit.rank_label)
 unit.rank_label.text="BOSS" if unit.enemy_rank=="boss" else "E"
 unit.update_lane_position()
