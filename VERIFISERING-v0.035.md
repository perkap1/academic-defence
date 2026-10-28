# Academic Defence v0.035 — new Book Tower artwork

Replaced Book Tower's old comic teacher with the supplied glasses/ponytail teacher sprite sheet. The PNG is copied unchanged (SHA256 B0BA26FF98E18CCB2ED6931DE755F0202D7594565F73F6900FE82FF7F6A5D3AC). Godot AtlasTexture regions supply five idle/coffee frames and four throw frames, with a common 600x500 canvas and bottom-center anchor. The same sheet is used at levels 1–3.

The existing static-base shader keeps the desk fixed. The gold level glyph is repositioned over a small red backing on the new banner. Existing 0.247 sprite scale, facing, world position, nearest filtering, stats, prices, upgrade logic, attack timing and spinning book projectile remain unchanged. No image generation, pixel edits or Aseprite were used.

Verification: comic-book suite 49 checks, presentation 85, tower size 16, upgrades 107, science 51, audio 31, unit layout 1690 and enemy ranks 8050, all zero failures. Native Godot renders of all nine frames were visually inspected. Web export succeeded.

Local test: http://127.0.0.1:8765/?v=0.035
