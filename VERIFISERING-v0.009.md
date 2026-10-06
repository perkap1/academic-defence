# v0.009 verification — 2026-10-06

Existing project updated in place; v0.008 upgrades and waterfall preserved.

- 3,142 headless checks passed, including full rounds on both maps.
- 428 graphical checks passed, including 144 new presentation checks and 60 rendered frames across both maps and all tower levels.
- Original transparent sheets used directly through Godot AtlasTexture; no Aseprite or raster editing.
- Book 4 FPS page-turn/rest sequence and 0.25-second attack tested; Blackboard static idle and four ordered attack frames tested at every level.
- Stable base sprite/pivots, level effects, arrow states, 70% unit scale, readable bars, independent lane RNG, bridge narrowing and continuous lateral positions verified.
- Path-progress speed is preserved. Outer lanes naturally cover slightly more world distance than inner lanes; continuity tests probe nearby positions rather than requiring equal arc lengths.
- Independent review found no gameplay/state defects. Cosmetic limitation: adjacent painted sponge halos overlap in the supplied sheet, so atlas boundaries can trim a halo edge; damage and slow are unaffected.
- Web export succeeded with index.html, JavaScript, PCK and WASM together.

Local play link: http://127.0.0.1:8765/
