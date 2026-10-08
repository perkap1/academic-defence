# Academic Defence v0.014 — enemy animation refresh

2026-10-08. Existing Godot project and gameplay retained.

- Supplied sheets copied intact to assets/enemies_v014; Godot AtlasTexture regions exclude sheet labels and borders.
- Normal Student, PE boy/girl and Bookworm (3/2/1/0 shields): two idle and four movement frames, front/side/back.
- Fixed per-set canvas, foot origin and source scale; unit node scale remains 0.7. Normal sprite 0.28, PE 0.43, Bookworm 0.73 accommodate different source resolutions.
- Idle plays at 2 FPS while held. Movement animates at 8 FPS (Normal/Bookworm), 10 FPS (PE). Route speeds remain 85 and 114.75.
- PE girl source has mixed side-facing poses; per-pose mirroring keeps the direction consistent.
- Bookworm shield swaps preserve animation phase, path progress and the existing falling-book reaction.
- Existing wave compositions, pathing, bars, rewards, tower combat and slow unchanged.

Validation:
- New regression observed failing before implementation; final enemy-refresh test: 218 checks, zero failures.
- All 24 existing headless regression scripts passed, including full Map 1/2/3 simulations, assistant combat, Bookworm shields and Science Tower.
- Godot-rendered frame grids inspected in all three directions for all types and shield states; corrected PE girl crop boundaries.
- Web release export succeeded with index.html, .js, .wasm and .pck.
- Local browser: v0.014 world map, Map 1, radial build, wave start/restart, pause and new students rendered; no captured console errors.

Local test: http://127.0.0.1:8765/?v=0.014
Publication uses the existing main-branch GitHub Pages workflow and unique asset filenames per commit.
