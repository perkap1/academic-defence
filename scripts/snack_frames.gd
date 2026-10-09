extends RefCounted
static var cached:Dictionary={}
static func create()->Dictionary:
 if not cached.is_empty(): return cached
 var sheet:Texture2D=load("res://assets/snack/sheet.png")
 for row in range(3):
  var direction=["front","side","back"][row]
  cached[direction]=[]
  for i in range(10):
   var left=roundi(i*144.8)
   var right=roundi((i+1)*144.8)
   var top=[185,440,700][row]
   var frame=AtlasTexture.new()
   frame.atlas=sheet
   frame.region=Rect2(left,top,right-left,220)
   var pivot=Vector2(left+(right-left)*0.5,[380,640,900][row])-frame.region.position
   frame.margin=Rect2(Vector2(90,210)-pivot,Vector2(180,240)-frame.region.size)
   frame.filter_clip=true
   cached[direction].append(frame)
 return cached
