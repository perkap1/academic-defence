# 🎮 Play the game

👉 **[PLAY GAME](https://perkap1.github.io/academic-defence/)**

# Academic Defence

A pixel-art tower defence game made in **Godot 4.4.1**. Teach students before they reach the bridge: students graduate at 100 Knowledge. This repository contains the existing project developed in this chat.

## Controls

- Choose Skogsstien or Elvesvingene on the world map. Complete Elvesvingene to unlock Bokruinene (Map 3).
- Click a **+** building spot and select Book Tower, Science Tower, Assistant or Study Hall in the radial menu.
- Click **Start bølge** to start the next wave. Towers attack automatically.
- Click a built Book/Science tower to inspect its stats and range. Use the green up arrow to upgrade to levels 2 and 3, or **SELL** for 50% of total investment. Assistant retains its existing rally controls.
- Use the pause button or **Esc** to pause/resume. Esc first closes an open building menu.
- **Kart** returns to the world map; **Ny** restarts the current map.

## Open and run in Godot

Import `project.godot` in Godot **4.4.1**, then press **F5**. All scenes, scripts, sprites and original source assets are included. Godot regenerates its ignored `.godot` cache on import.

```sh
godot --editor --path .
godot --path .
```

## Run the web version locally

The Web preset uses the included official Godot 4.4.1 single-threaded export templates, so it works with GitHub Pages without cross-origin isolation headers.

```sh
mkdir -p build/web
godot --headless --path . --editor --import
godot --headless --path . --export-release Web build/web/index.html
python -m http.server 8765 --directory build/web
```

Open http://127.0.0.1:8765/ . Keep all exported files together; do not open index.html directly from disk. Use matching templates if you change the Godot version.

## Current status

**v0.015 — playable prototype.** Three maps (7, 12 and 15 waves), normal and PE students and The Bookworm on all three maps, Book, Science and Teaching Assistant towers, economy buildings, tower upgrades/selling, pause, restart, radial building menu and shared graduation animation. Book Tower throws spinning books from a comic brick tower; levels share the same character art with gold 1/2/3 banner digits. Tower artwork is displayed at 65% of its original size (30% larger than v0.014.1); Book and Science teachers face the map entrance while level digits remain readable. Normal Student, PE boy/girl and all four Bookworm shield states now use the new comic enemy sheets with two idle and four movement frames per direction. Held students animate without moving; PE runs animate faster while retaining existing route speed. Science Tower uses the new comic science teacher, animated green/purple orbs and color clouds. All three levels share stable tower art with gold digits; its existing AoE Knowledge and non-stacking slow remain unchanged. Map 3 unlocks after completing Map 2; two further world-map nodes remain locked. Level progress is saved locally in Godot and in the browser's storage for the Web version.

See `VERIFISERING-v0.015.md` for the latest checks and `VERIFISERING.md` for earlier verification.

## Automatic publishing

Push to **main** to run headless gameplay regression tests, export this same Godot project and deploy it to GitHub Pages. Failed tests or exports stop deployment. The workflow can also be started manually from Actions. No separate game source copy is used.

Workflow: `.github/workflows/pages.yml`. Deployment follows [GitHub's Pages workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Teaching Assistant Post

Assistant costs120KP and spawns2 assistants. Each holds one student for3seconds and teaches5Knowledge/second (15total), then returns to its rally and cools down for0.8seconds. Select the post and click near the road within its260radius to move rally. Selling refunds60KP and releases held students.

v0.009 includes Teaching Assistant Post, ambient animations, tower upgrades and the new tower presentation.

## v0.007 — ambient animation

The current source and Web export include five subtle four-frame loops authored in Aseprite: water, waterfall, bush, crown leaves and plant. Both maps use a reusable AnimatedSprite2D background layer with nearest filtering, fixed origins and inherited pause behavior. Editable sources are in `assets/environment/source/`.

Play the latest published version using the GitHub Pages link above. Local test link: http://127.0.0.1:8765/ .


## Tower upgrades (v0.008)

Book Tower upgrades cost 80 and 130 KP: level 2 teaches 25 Knowledge every 0.8 seconds at range 286; Scholar Tower teaches 30 every 0.65 seconds at range 312. Every fifth Scholar letter is Golden and teaches 60 Knowledge.

Blackboard upgrades cost 100 and 150 KP: level 2 teaches 19 Knowledge, with AoE radius 126 and 30% slow for 2.5 seconds. Master Blackboard teaches 22, with radius 147 and 40% slow for 2.5 seconds. Attack interval and tower range remain 1.3 seconds and 225. Slow refreshes without stacking; the strongest active slow remains until expiry.

Clicking ground or selecting another spot closes the compact tower banner and range circle. Upgrade price is always shown; insufficient funds and maximum level disable purchase.

## Presentation and unit lanes (v0.009)

Supplied original sheets are used directly as Godot atlases. Book towers turn pages at 4 FPS, rest open for four periods, and briefly show their golden attack frame. Blackboard towers stay still between attacks, then play four attack frames with blue (levels 1–2) or purple (level 3) sponge effects. The supplied upgrade arrow includes hover, pressed and disabled states.

Students and teaching assistants are 70% of their previous visual size. Knowledge bars keep their readable dimensions. Students use small independent lateral offsets that narrow at bridges and bends; assistants meet their actual positions. Existing stats, wave timing, maps and paths remain unchanged.

Local verification: **3,570 checks, 0 failures**, including graphical tests and complete rounds on both maps. See `VERIFISERING-v0.009.md`. Local Web build: http://127.0.0.1:8765/ .


## v0.009.1 — consistent Normal Student animation
Normal Student now uses fixed atlas regions from the original sheet, a shared foot pivot and identical scale for every pose. The old individually resized assets are retained. PE students and gameplay are unchanged. Verified all 18 poses visually and 1,869 targeted regression checks.


## v0.009.2 — shared Assistant information banner
Teaching Assistant Post uses the same fixed bottom banner as Book and Blackboard: icon, teaching rate, hold duration, range, rally guidance and Sell. Its upgrade arrow is disabled; no Assistant upgrades or gameplay changes are introduced. Both maps checked visually; 181 targeted regression checks passed.


## Economy buildings (v0.010)

Study Hall costs 100 KP and pays 15 KP after each completed wave. Select it to choose one exclusive specialization for 120 KP:

- **Library:** 45 KP per wave.
- **Scholarship Office:** 10 KP per wave, plus 5 KP when a student graduates within its 260 radius, capped at 50 bonus KP per wave. Overlapping Offices award each student only once; the cap resets when the next wave starts. Select an Office to see its radius.

All four use the common bottom banner, four calm idle frames and a short active frame with an income popup. Selling refunds 50% of the total investment: 50 KP for Study Hall, 110 KP for a specialization. Existing combat and maps are unchanged.

Verified 3,310 headless checks and 92 graphical checks, including real UI purchases on both maps, all student variants, income caps, wave deduplication and sale cleanup.

## Map 3 and The Bookworm (v0.011)

Bokruinene uses the supplied forest/ruins map with two alternating entrances, a shared exit, 14 building spots and 15 waves. Bookworms begin in wave 4 and walk at Normal Student speed. Three books shield them: each Knowledge hit removes one book and gives zero Knowledge, including the hit that removes the last book. Later hits teach normally. Golden Letters and Blackboard AoE still remove at most one book per attack event; slows and Assistant lessons work through the shield.

Each shield loss plays a short comic book-fall reaction without changing the student's path progress. All four shield states use the original sprite sheet, and graduation and rewards follow the existing rules. A brief first-encounter explanation appears once. No Aseprite work or changes to the earlier maps' balance were needed.

## Comic Book Tower (v0.012)

The supplied original sheets replace Book Tower art at all three levels. Eight calm reading/coffee idle frames loop at 3 FPS; four throw poses run for 0.4 seconds on each attack. A fixed lower brick base and independently drawn gold pixel numeral keep the footing and level banner stable. The radial build icon and tower information portrait use the new character.

Projectiles use one supplied book frame, centered and spun in Godot at 12 radians/second with nearest filtering. Targeting, flight speed, one-spend collision, Knowledge, upgrade costs/stats and selling are preserved. Every fifth Level 3 book remains Golden and deals twice the normal Knowledge; Bookworm shielding still removes only one book per hit. No Aseprite was used; earlier assets remain in the project.
