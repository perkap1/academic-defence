extends "res://tests/test_pe_teacher.gd"
func run():
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 main.hide();main.ui.get_node("HUD").hide()
 var board=Node2D.new();root.add_child(board);board.process_mode=Node.PROCESS_MODE_DISABLED
 var bg=ColorRect.new();bg.color=Color("c0c5b6");bg.size=Vector2(1672,1131);board.add_child(bg)
 var names=["Normal","PE boy","PE girl","Bookworm","Snack","Clown","Pilot"]
 var kinds=["normal","pe","pe","bookworm","snack","clown","pilot"]
 for i in range(7):
  var title=Label.new();title.text=names[i];title.position=Vector2(110+i*225,25);title.add_theme_color_override("font_color",Color("172229"));title.add_theme_font_size_override("font_size",22);board.add_child(title)
 for row in range(3):
  var label=Label.new();label.text=["NORMAL","ELITE 2.5x","BOSS 5x"][row];label.position=Vector2(10,80+row*325);label.add_theme_color_override("font_color",Color("172229"));board.add_child(label)
  for i in range(7):
   var unit=pupil(main,kinds[i],main.map.route,200,"girl" if i in [2,6] else "boy")
   unit.reparent(board);unit.position=Vector2(150+i*225,275+row*325);unit.scale=Vector2.ONE*1.3
   unit.direction="front";unit.sprite.flip_h=false;unit.sprite.texture=unit.frames.front[2]
   if row>0:
    unit.set_enemy_rank("elite" if row==1 else "boss",2.5 if row==1 else 5)
    unit.rank_material.set_shader_parameter("actor_origin",unit.global_position)
    unit.rank_material.set_shader_parameter("actor_scale",1.3)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/enemy-ranks-board.png")
 for facing in ["side","back"]:
  for unit in board.get_children():
   if unit is PathFollow2D:
    unit.direction=facing;unit.sprite.texture=unit.frames[facing][2];unit.update_rank_pose()
  await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://../../work/enemy-ranks-%s.png"%facing)
 board.free();main.free();quit()
