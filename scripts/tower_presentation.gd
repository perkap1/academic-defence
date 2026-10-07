extends RefCounted
# Original sheets stay intact. Atlas margins provide a common pivot and canvas.
const BASE_SHADER=preload("res://scripts/tower_base.gdshader")
const BOOK_CELLS=[[0,311,587,863,1142,1448],[0,311,587,863,1140,1448],[0,301,581,862,1143,1448]]
const BOOK_ROWS=[Vector2(0,351),Vector2(352,681),Vector2(684,1053)]
const BOOK_PIVOTS=[[[175,345],[450,345],[724,345],[1000.5,345],[1280.5,344]],[[175,677],[448,677],[723.5,677],[999.5,677],[1278.5,677]],[[161.5,1041],[440,1041],[723,1041],[1001,1041],[1282.5,1044]]]
const BOARD_CELLS=[0,350,660,964,1272,1619]
const BOARD_ROWS=[Vector2(0,291),Vector2(300,600),Vector2(600,956)]
const BOARD_PIVOTS=[[[189,278],[507,278],[808.5,278],[1114,278],[1425,278]],[[187.5,594],[505,593],[809,593],[1113.5,594],[1428,592]],[[185,944],[502.5,944],[809,944],[1115,944],[1429,944]]]
static func atlas(sheet:Texture2D,region:Rect2,pivot:Vector2,canvas:Vector2=Vector2(400,400),anchor:Vector2=Vector2(200,365))->AtlasTexture:
 var frame=AtlasTexture.new()
 frame.atlas=sheet
 frame.region=region
 frame.margin=Rect2(anchor-(pivot-region.position),canvas-region.size)
 frame.filter_clip=true
 return frame
static func tower_frames(kind:String,level:int)->Array:
 if kind=="book": return comic_book_frames()
 var sheet:Texture2D=load("res://assets/presentation/%s_sheet.png"%kind)
 var row:Vector2=BOOK_ROWS[level-1] if kind=="book" else BOARD_ROWS[level-1]
 var cells:Array=BOOK_CELLS[level-1] if kind=="book" else BOARD_CELLS
 var pivots:Array=BOOK_PIVOTS[level-1] if kind=="book" else BOARD_PIVOTS[level-1]
 var frames=[]
 for i in range(5):
  var rect=Rect2(cells[i],row.x,cells[i+1]-cells[i],row.y-row.x)
  frames.append(atlas(sheet,rect,Vector2(pivots[i][0],pivots[i][1])))
 return frames
static func comic_book_frames()->Array:
 var sheet:Texture2D=load("res://assets/presentation/comic_book_sheet.png")
 var result=[]
 var cells=[60,400,735,1065,1424]
 var rows=[Vector2(0,383),Vector2(383,765),Vector2(765,1086)]
 var centers=[[235,568,902,1237],[233,568,903,1237],[236,565,909,1236]]
 var feet=[380,761,1080]
 for row in range(3):
  for i in range(4):
   var right:float=796 if row==2 and i==1 else cells[i+1]
   result.append(atlas(sheet,Rect2(cells[i],rows[row].x,right-cells[i],rows[row].y-rows[row].x),Vector2(centers[row][i],feet[row]),Vector2(440,420),Vector2(220,385)))
 return result
static func thrown_book()->AtlasTexture:
 var sheet:Texture2D=load("res://assets/presentation/thrown_book.png")
 return atlas(sheet,Rect2(355,280,525,710),Vector2(617.5,635),Vector2(600,760),Vector2(300,380))
static func apply(tower)->void:
 tower.frames=tower_frames(tower.tower_type,tower.level)
 var factor:float=0.38 if tower.tower_type=="book" else [0.54,0.48,0.44][tower.level-1]
 tower.sprite.position=Vector2(0,-3)
 tower.sprite.offset=Vector2(-220,-385) if tower.tower_type=="book" else Vector2(-200,-365)
 tower.sprite.centered=false
 tower.sprite.scale=Vector2.ONE*factor
 tower.sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 if tower.base_sprite==null:
  tower.base_sprite=Sprite2D.new()
  tower.add_child(tower.base_sprite)
  tower.move_child(tower.base_sprite,0)
 var base:Sprite2D=tower.base_sprite
 base.position=tower.sprite.position
 base.offset=tower.sprite.offset
 base.centered=false
 base.scale=tower.sprite.scale
 base.texture=tower.frames[0]
 base.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var cut:float=-180.0 if tower.tower_type=="book" else [-54.0,-66.0,-88.0][tower.level-1]
 for pair in [[base,false],[tower.sprite,true]]:
  var material=ShaderMaterial.new()
  material.shader=BASE_SHADER
  material.set_shader_parameter("cut_y",cut)
  material.set_shader_parameter("upper",pair[1])
  pair[0].material=material
 tower.sprite.texture=tower.frames[0]
static func sponge_frames(level:int)->Array:
 var sheet:Texture2D=load("res://assets/presentation/sponge_sheet.png")
 var rows=[Vector2(80,355),Vector2(378,691),Vector2(695,1062)]
 var centers=[235.0,535.0,875.0]
 var row:Vector2=rows[level-1]
 var result=[]
 for i in range(5):
  var left=floorf(i*1448.0/5)
  var right=floorf((i+1)*1448.0/5)
  result.append(atlas(sheet,Rect2(left,row.x,right-left,row.y-row.x),Vector2((left+right)*0.5,centers[level-1]),Vector2(360,400),Vector2(180,200)))
 return result
static func arrow_frames()->Array:
 var sheet:Texture2D=load("res://assets/presentation/upgrade_sheet.png")
 var pivots=[Vector2(235,527),Vector2(670,527),Vector2(1085,525),Vector2(1507,523)]
 var result=[]
 for i in range(4):
  var left=floorf(i*2172.0/5)
  var right=floorf((i+1)*2172.0/5)
  result.append(atlas(sheet,Rect2(left,150,right-left,390),pivots[i],Vector2(480,420),Vector2(240,390)))
 return result
