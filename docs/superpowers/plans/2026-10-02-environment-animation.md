# Environment animation implementation — v0.007

Keep the existing maps and gameplay. Author five reusable transparent four-frame loops in Aseprite: water ripple, waterfall, bush, crown leaves, plant. Retain editable Aseprite files and authoring script. Place only a few small patches over appropriate existing artwork; Map 1 has no waterfalls.

Use one visual Node2D layer behind gameplay with AnimatedSprite2D children, cached SpriteFrames, nearest filtering, fixed positions, deterministic phase offsets and inherited pause behavior. No input, collision, RNG, route or tower changes. Exclude editable art sources from Web export.

Verify missing layer before implementation; check frame counts, layer ordering, placement kinds and preserved slots. Render both maps, confirm animation advancement and fixed origins, exercise waves/towers. Run existing gameplay regression tests, export the same game to Web and test locally.
