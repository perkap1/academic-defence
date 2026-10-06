extends RefCounted
# Fixed source-pixel scale, canvas and foot pivot; never resize individual poses.
static func create()->Dictionary:
 var sheet:Texture2D=load("res://assets/normal_students.png")
 var centers=[190,456,739,1014,1299,1584]
 var boundaries=[75,320,600,885,1168,1450,1725]
 var result={}
 var directions=["front","side","back"]
 var rows=[Vector2(0,295),Vector2(295,580),Vector2(580,872)]
 var feet=[292,570,858]
 for row in range(3):
  result[directions[row]]=[]
  for i in range(6):
   var frame=AtlasTexture.new()
   frame.atlas=sheet
   frame.region=Rect2(boundaries[i],rows[row].x,boundaries[i+1]-boundaries[i],rows[row].y-rows[row].x)
   var pivot=Vector2(centers[i],feet[row])-frame.region.position
   frame.margin=Rect2(Vector2(150,310)-pivot,Vector2(300,320)-frame.region.size)
   frame.filter_clip=true
   result[directions[row]].append(frame)
 return result

