extends RefCounted
const Atlas=preload("res://scripts/tower_presentation.gd")
static var cached:Dictionary={}
static var source_image:Image
static func grounded(sheet:Texture2D,region:Rect2,pivot:Vector2,canvas:Vector2,anchor:Vector2)->AtlasTexture:
 if source_image==null:source_image=sheet.get_image()
 var used:Rect2i=source_image.get_region(Rect2i(region)).get_used_rect()
 pivot.y=region.position.y+used.end.y
 return Atlas.atlas(sheet,region,pivot,canvas,anchor)
static func create()->Dictionary:
 if not cached.is_empty():return cached
 var sheet:Texture2D=load("res://assets/class_clown/sheet.png")
 var idle_bounds=[[210,360,515],[570,720,875],[940,1085,1240]]
 var idle_centers=[[289,435],[645,800],[1017,1163]]
 var move_bounds=[[0,115,230,345,460],[490,605,720,835,950],[980,1097,1214,1331,1448]]
 var cast_bounds=[[0,114,211,306,401,494],[494,590,686,782,878,974],[974,1069,1164,1259,1354,1448]]
 var hit_bounds=[0,218,400]
 var defeat_bounds=[400,610,785,950,1215,1448]
 for row in range(3):
  var list=[]
  for i in range(2):list.append(grounded(sheet,Rect2(idle_bounds[row][i],20,idle_bounds[row][i+1]-idle_bounds[row][i],250),Vector2(idle_centers[row][i],260),Vector2(280,300),Vector2(140,285)))
  for i in range(4):
   var left:int=move_bounds[row][i];var right:int=move_bounds[row][i+1]
   list.append(grounded(sheet,Rect2(left,280,right-left,210),Vector2((left+right)/2.0,480),Vector2(280,300),Vector2(140,285)))
  for i in range(5):
   var left:int=cast_bounds[row][i];var right:int=cast_bounds[row][i+1]
   list.append(grounded(sheet,Rect2(left,500,right-left,245),Vector2((left+right)/2.0,732),Vector2(280,300),Vector2(140,285)))
  for i in range(2):list.append(grounded(sheet,Rect2(hit_bounds[i],770,hit_bounds[i+1]-hit_bounds[i],285),Vector2((hit_bounds[i]+hit_bounds[i+1])/2.0,1038),Vector2(280,300),Vector2(140,285)))
  for i in range(5):list.append(Atlas.atlas(sheet,Rect2(defeat_bounds[i],770,defeat_bounds[i+1]-defeat_bounds[i],316),Vector2((defeat_bounds[i]+defeat_bounds[i+1])/2.0,1044),Vector2(400,340),Vector2(200,310)))
  cached[["front","side","back"][row]]=list
 return cached
static func confetti()->Array:
 var sheet:Texture2D=load("res://assets/class_clown/confetti.png")
 var bounds=[0,240,570,960,1450,1880,2172];var result=[]
 for i in range(6):result.append(Atlas.atlas(sheet,Rect2(bounds[i],130,bounds[i+1]-bounds[i],495),Vector2((bounds[i]+bounds[i+1])/2.0,390),Vector2(600,600),Vector2(300,300)))
 return result
static func icon()->Texture2D:
 var image=load("res://assets/class_clown/sheet.png").get_image().get_region(Rect2i(220,30,140,235))
 image.resize(10,16,Image.INTERPOLATE_NEAREST)
 var canvas=Image.create(16,16,false,Image.FORMAT_RGBA8);canvas.fill(Color.TRANSPARENT);canvas.blit_rect(image,Rect2i(0,0,10,16),Vector2i(3,0))
 return ImageTexture.create_from_image(canvas)
