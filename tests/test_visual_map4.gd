extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main_map4.tscn").instantiate()
 root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED
 var routes=[]
 for path in main.map.get_routes():
  var points=[]
  for distance in range(0,int(path.curve.get_baked_length()),6):
   var point=path.curve.sample_baked(distance)
   points.append([point.x,point.y])
  routes.append(points)
  var line=Line2D.new();line.width=3;line.default_color=Color(1,0,1,0.8)
  for point in path.curve.get_baked_points():line.add_point(point)
  main.map.add_child(line)
  for distance in range(150,int(path.curve.get_baked_length())-150,220):
   var s=load("res://scenes/snack_monster.tscn" if distance%3==0 else "res://scenes/student.tscn").instantiate()
   path.add_child(s);s.progress=distance;s.update_lane_position();s._process(0)
 var file=FileAccess.open("res://../map4-routes.json",FileAccess.WRITE);file.store_string(JSON.stringify(routes));file.close()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../AcademicDefence-map4-paths.png"))
 main.free();quit()
