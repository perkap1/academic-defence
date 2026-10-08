extends RefCounted
# Fixed source-pixel scale, canvas and foot pivot; never resize individual poses.
static func create()->Dictionary:
 var sheet:Texture2D=load("res://assets/enemies_v014/normal.png")
 var centers_by_row=[[155,445,750,1040,1345,1644],[150,450,745,1045,1335,1630],[160,455,755,1043,1340,1640]]
 var boundaries=[0,300,600,895,1195,1490,1774]
 var result={}
 var directions=["front","side","back"]
 var rows=[Vector2(0,295),Vector2(295,580),Vector2(580,887)]
 var feet=[294,575,862]
 for row in range(3):
  result[directions[row]]=[]
  for i in range(6):
   var frame=AtlasTexture.new()
   frame.atlas=sheet
   frame.region=Rect2(boundaries[i],rows[row].x,boundaries[i+1]-boundaries[i],rows[row].y-rows[row].x)
   var pivot=Vector2(centers_by_row[row][i],feet[row])-frame.region.position
   frame.margin=Rect2(Vector2(150,310)-pivot,Vector2(300,320)-frame.region.size)
   frame.filter_clip=true
   result[directions[row]].append(frame)
 return result

