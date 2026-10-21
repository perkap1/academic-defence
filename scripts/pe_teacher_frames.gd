extends RefCounted
const Presentation=preload("res://scripts/tower_presentation.gd")
const PIVOTS=[Vector2(147,918),Vector2(415,918),Vector2(676,918),Vector2(938,918),Vector2(1206,918)]
# Only the actor and held medicine ball animate. The platform and basket are
# taken from idle and stay fixed, despite their different sizes on the sheet.
const ACTORS=[
 [Vector2(0,550),Vector2(209,550),Vector2(209,695),Vector2(253,725),Vector2(260,799),Vector2(232,843),Vector2(62,843),Vector2(0,808)],
 [Vector2(305,550),Vector2(530,550),Vector2(530,700),Vector2(512,731),Vector2(520,808),Vector2(480,842),Vector2(340,842),Vector2(305,809)],
 [Vector2(550,550),Vector2(786,550),Vector2(786,700),Vector2(781,736),Vector2(781,809),Vector2(750,842),Vector2(590,842),Vector2(550,808)],
 [Vector2(840,550),Vector2(1065,550),Vector2(1065,700),Vector2(1051,723),Vector2(1080,759),Vector2(1080,817),Vector2(852,839),Vector2(840,807)],
 [Vector2(1112,550),Vector2(1418,550),Vector2(1441,709),Vector2(1390,733),Vector2(1350,736),Vector2(1307,811),Vector2(1112,811)]
]
static func actor_material(index:int)->ShaderMaterial:
 var material=ShaderMaterial.new();material.shader=preload("res://scripts/pe_actor.gdshader")
 var points=PackedVector2Array()
 if index<4:
  for point in [Vector2(65,70),Vector2(315,70),Vector2(315,220),Vector2(278,240),Vector2(278,382),Vector2(65,382)]:points.append(point-Vector2(213,501))
 else:
  for point in ACTORS[index-4]:points.append(point-PIVOTS[index-4])
 material.set_shader_parameter("point_count",points.size())
 points.resize(16);material.set_shader_parameter("outline",points)
 return material
static func create()->Array:
 var sheet:Texture2D=load("res://assets/presentation/pe_teacher_sheet.png")
 var result=[]
 var cells=[0,420,796,1164,1536]
 var pivots=[Vector2(213,501),Vector2(590,501),Vector2(966,501),Vector2(1337,501)]
 for i in range(4):
  result.append(Presentation.atlas(sheet,Rect2(cells[i],70,cells[i+1]-cells[i],440),pivots[i],Vector2(700,600),Vector2(350,560)))
 cells=[0,288,550,812,1080,1536]
 pivots=PIVOTS
 for i in range(5):
  result.append(Presentation.atlas(sheet,Rect2(cells[i],550,cells[i+1]-cells[i],380),pivots[i],Vector2(700,600),Vector2(350,560)))
 return result
static func fixed_basket()->AtlasTexture:
 return Presentation.atlas(load("res://assets/presentation/pe_teacher_sheet.png"),Rect2(270,211,145,170),Vector2(213,501),Vector2(700,600),Vector2(350,560))
static func ball()->AtlasTexture:
 return Presentation.atlas(load("res://assets/presentation/medicine_ball_sheet.png"),Rect2(40,245,350,320),Vector2(215,405),Vector2(360,340),Vector2(180,170))
static func speed()->Array:
 var sheet:Texture2D=load("res://assets/presentation/medicine_ball_sheet.png")
 var cells=[405,690,1035,1448];var result=[]
 for i in range(3):
  result.append(Presentation.atlas(sheet,Rect2(cells[i],300,cells[i+1]-cells[i],270),Vector2(cells[i+1]-10,440),Vector2(440,320),Vector2(420,160)))
 return result
static func dust()->Array:
 var sheet:Texture2D=load("res://assets/presentation/medicine_ball_sheet.png")
 var cells=[25,350,725,1080,1448];var result=[]
 for i in range(4):
  result.append(Presentation.atlas(sheet,Rect2(cells[i],700,cells[i+1]-cells[i],270),Vector2((cells[i]+cells[i+1])*0.5,940),Vector2(400,300),Vector2(200,260)))
 return result
