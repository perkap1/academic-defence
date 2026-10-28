extends SceneTree
func _initialize():call_deferred("run")
func run():
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);main.process_mode=Node.PROCESS_MODE_DISABLED;main.visible=false
 main.ui.get_node("HUD").hide()
 var board=Node2D.new();root.add_child(board)
 var background=ColorRect.new();background.color=Color("697b73");background.size=Vector2(1672,1131);board.add_child(background)
 for i in range(9):
  var tower=load("res://scenes/book_tower.tscn").instantiate();board.add_child(tower);tower.configure(main.map,main.game)
  tower.position=Vector2(175+(i%5)*330,480 if i<5 else 1060);tower.scale=Vector2.ONE*2.5
  tower.animation_time=0 if i<5 else 0.4-(i-5)*0.1;tower.visual_time=float(i)/3.0+0.001;tower.update_sprite(0)
  tower.level=1+i%3;tower.get_node("LevelBadge").queue_redraw()
  var label=Label.new();label.text=("Idle %d"%(i+1)) if i<5 else ("Throw %d"%(i-4));label.position=Vector2(tower.position.x-50,40 if i<5 else 590);board.add_child(label)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://../../work/book-teacher-board.png")
 main.free();board.free();quit()
