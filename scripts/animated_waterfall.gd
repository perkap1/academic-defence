extends AnimatedSprite2D
## Water-only overlay. Atlas frames share one canvas and a top-left origin.
## Set this path to the map's existing background when reusing the scene.
@export_node_path("Sprite2D") var background_path: NodePath = NodePath("../Background")

func _ready() -> void:
 refresh_background_mask()

func refresh_background_mask() -> void:
 var background := get_node_or_null(background_path) as Sprite2D
 if background == null or background.texture == null:
  push_error("AnimatedWaterfall needs the existing map Background Sprite2D")
  visible = false
  return
 # Each instance owns its mask, so configuring a copy cannot move another fall.
 var mask_material := material.duplicate() as ShaderMaterial
 material = mask_material
 var origin := background.to_local(global_position)
 var x_axis := background.to_local(to_global(Vector2.RIGHT)) - origin
 var y_axis := background.to_local(to_global(Vector2.DOWN)) - origin
 origin -= background.offset
 if background.centered:
  origin += background.texture.get_size() * 0.5
 mask_material.set_shader_parameter("map_texture",background.texture)
 mask_material.set_shader_parameter("map_origin",origin)
 mask_material.set_shader_parameter("map_x_axis",x_axis)
 mask_material.set_shader_parameter("map_y_axis",y_axis)
