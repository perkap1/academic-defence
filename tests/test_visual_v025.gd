extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map5.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var colors=[Color.CORAL,Color.LIME_GREEN,Color.CYAN,Color.MAGENTA]
 var r:=0
 for route in main.map.get_routes():
  var line=Line2D.new();line.width=4;line.default_color=colors[r];line.z_index=10
  for d in range(0,int(route.curve.get_baked_length()),4):line.add_point(route.curve.sample_baked(d))
  main.map.add_child(line)
  for i in range(5):
   var unit=load("res://scenes/student.tscn").instantiate();route.add_child(unit);unit.progress_ratio=0.12+i*0.18;unit.update_lane_position();unit._process(0.01)
  r+=1
 var i:=0
 for slot in main.map.slots.get_children():
  var label=Label.new();label.text=str(i);label.position=slot.position+Vector2(-8,30);label.add_theme_font_size_override("font_size",22);label.z_index=12;main.map.add_child(label);i+=1
 main.update_ui()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-v025-routes.png"))
 main.free();quit()
