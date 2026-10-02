extends Node2D
## Small ambient patches placed in the existing artwork, never on the road.
## No input, physics or gameplay state; AnimatedSprite2D handles playback.
const PLACEMENTS := {
 1: {
  "water": [Vector2(286,109),Vector2(403,727),Vector2(186,847),Vector2(538,889),Vector2(1636,811)],
  "bush": [Vector2(1280,426),Vector2(1063,893)],
  "leaves": [Vector2(735,714),Vector2(1214,842)],
  "plant": [Vector2(584,335),Vector2(1242,412)]
 },
 2: {
  "water": [Vector2(382,245),Vector2(1420,273),Vector2(289,825),Vector2(689,870),Vector2(1549,825)],
  "waterfall": [Vector2(85,680),Vector2(1515,214)],
  "bush": [Vector2(359,298),Vector2(842,543),Vector2(1460,674)],
  "leaves": [Vector2(440,610),Vector2(774,486),Vector2(1395,758)],
  "plant": [Vector2(1090,690),Vector2(1040,202)]
 }
}
const FPS := {"water":3.0,"waterfall":5.0,"bush":2.0,"leaves":1.666667,"plant":2.0}
static var frame_cache: Dictionary = {}
func configure(map_id: int) -> void:
 name = "Environment"
 z_index = -9
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 var placements: Dictionary = PLACEMENTS.get(map_id,{})
 var phase := 0
 for kind in placements:
  if not frame_cache.has(kind):
   var frames := SpriteFrames.new()
   frames.remove_animation("default")
   frames.add_animation("loop")
   frames.set_animation_loop("loop",true)
   frames.set_animation_speed("loop",FPS[kind])
   for index in range(4):
    frames.add_frame("loop",load("res://assets/environment/%s_%d.png" % [kind,index]))
   frame_cache[kind] = frames
  for point in placements[kind]:
   var sprite := AnimatedSprite2D.new()
   sprite.name = "%s_%d" % [kind,phase]
   sprite.set_meta("kind",kind)
   sprite.position = point
   sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
   sprite.sprite_frames = frame_cache[kind]
   add_child(sprite)
   sprite.play("loop")
   # Deterministic offsets avoid synchronized loops without touching gameplay RNG.
   sprite.set_frame_and_progress(phase % 4,float(phase % 3)/3.0)
   phase += 1
