extends RefCounted
# Fixed source scale per sheet, common foot pivot; Godot performs nearest cropping.
static var cache := {}
static func pose(file:String,rect:Rect2i,pivot:Vector2,factor:float)->Texture2D:
 var key="%s:%s:%s:%s"%[file,rect,pivot,factor]
 if cache.has(key): return cache[key]
 var source:Texture2D=load("res://assets/buildings_v015/"+file+".png")
 var image=source.get_image().get_region(rect)
 image.resize(roundi(rect.size.x*factor),roundi(rect.size.y*factor),Image.INTERPOLATE_NEAREST)
 var canvas=Image.create(360,320,false,Image.FORMAT_RGBA8)
 var offset=Vector2(180,290)-(pivot-Vector2(rect.position))*factor
 canvas.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(offset.round()))
 var texture=ImageTexture.create_from_image(canvas)
 cache[key]=texture
 return texture
static func economy(branch:String)->Array:
 var result=[]
 if branch=="study":
  for i in range(4): result.append(pose("study_a",Rect2i(i*313,385,313,375),Vector2(157+i*313,750),0.66))
  for i in range(4): result.append(pose("study_b",Rect2i(i*543,120,543,570),Vector2(270+i*543,675),0.45))
  result.append(pose("study_a",Rect2i(450,765,365,430),Vector2(630,1180),0.66))
 elif branch=="library":
  for i in range(9):
   var row=int(i/3)
   var column=i%3
   var left=[160,620,1080][column]
   var top=[0,313,622][row]
   result.append(pose("library",Rect2i(left,top,465,319),Vector2(left+230,[306,618,935][row]),0.77))
 elif branch=="scholarship":
  for i in range(10):
   var row=int(i/5)
   var column=i%5
   result.append(pose("scholarship",Rect2i(column*280,200+row*410,280,405),Vector2(column*280+140,575+row*423),0.65))
 return result
static func post_idle()->Array:
 var result=[]
 for i in range(4): result.append(pose("post",Rect2i([30,250,470,690][i],0,225,220),Vector2([142,362,582,802][i],217),0.84))
 return result
static func pointing(direction:String)->Array:
 var sets={"up":[1,0],"down":[1,3],"left":[2,0],"right":[2,3],"up_left":[3,0],"up_right":[3,3],"down_left":[4,0],"down_right":[4,3]}
 var entry:Array=sets[direction]
 var result=[]
 for i in range(3):
  var column:int=entry[1]+i
  var left=[30,260,490,750,980,1210][column]
  var top=[0,224,439,654,874][entry[0]]
  var frame=pose("post",Rect2i(left,top,mini(238,1448-left),212),Vector2(left+119,top+207),0.84)
  if (direction=="left" and i==2) or (direction=="right" and i==0) or (direction=="down_left" and i==2):
   var image=frame.get_image()
   image.flip_x()
   frame=ImageTexture.create_from_image(image)
  result.append(frame)
 return result
