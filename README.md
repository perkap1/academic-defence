# 🎮 Play the game

👉 **[PLAY GAME](https://perkap1.github.io/academic-defence/)**

# Academic Defence

A pixel-art tower defence game made in **Godot 4.4.1**. Teach students before they reach the bridge: students graduate at 100 Knowledge. This repository contains the existing v0.006 project developed in this chat.

## Controls

- Choose Skogsstien or Elvesvingene on the world map.
- Click a **+** building spot and select Book Tower or Blackboard Tower in the radial menu.
- Click **Start bølge** to start the next wave. Towers attack automatically.
- Click a built tower to inspect its range or sell it using **SELL**.
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

**v0.006 — playable prototype.** Two playable maps (7 and 12 waves), normal and PE students, Book, Blackboard and Teaching Assistant towers, tower selling, pause, restart, radial building menu and shared graduation animation. Book Tower fires randomly selected animated A/B/C projectiles. Blackboard Tower uses a sponge swipe with splash and droplets while its 30% slow is active for 2 seconds; new hits refresh the duration without stacking. Three further world-map nodes remain locked.

The earlier v0.005 verification recorded 1,117 successful checks, including full rounds on both maps and graphical tests. See `VERIFISERING.md` for details.

## Automatic publishing

Push to **main** to run headless gameplay regression tests, export this same Godot project and deploy it to GitHub Pages. Failed tests or exports stop deployment. The workflow can also be started manually from Actions. No separate game source copy is used.

Workflow: `.github/workflows/pages.yml`. Deployment follows [GitHub's Pages workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Teaching Assistant Post

Assistant costs120KP and spawns2 assistants. Each holds one student for3seconds and teaches5Knowledge/second (15total), then returns to its rally and cools down for0.8seconds. Select the post and click near the road within its260radius to move rally. Selling refunds60KP and releases held students.

Current version: **v0.006**, including Teaching Assistant Post. Latest local verification: **1,244 checks, 0 failures**.
