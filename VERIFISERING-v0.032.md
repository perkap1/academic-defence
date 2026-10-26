# Academic Defence v0.032 — original 8-bit effects

- Nine original, locally generated WAV effects for Book, Science and PE Teacher launch/impact, construction, upgrade/specialization and graduation.
- Effects follow actual gameplay events; no changes to attacks, knowledge, economy, pathfinding or wave balance.
- Ten reusable voices, at most six combat voices, per-effect rate limits and room for building/graduation feedback. No sound nodes added per shot.
- Separate Effects bus, 55% default volume, immediate mute and 0–100% volume. Settings saved separately from campaign progress.
- LYD controls on the world map and pause menu; usable while paused and remembered after scene changes/reloading.
- Original synthesis source included, without external samples or tools to install.

Verification: all 56 regression suites passed, including complete campaigns on maps 1–5. The new audio test has 31 passing checks and was also run with native WASAPI output. Silent Dummy-driver tests avoid allocating WAV playbacks because that driver has no mixer to release them. Native mixer tests wait for stopped buffers to drain before quitting. No remaining errors in the final runs.

All nine assets checked for correct mono sample rate, duration and peak level. Web export succeeded. World-map and pause-menu controls tested in the browser; changed volume/mute survived page reload, and browser error log remained empty.

Local test: http://127.0.0.1:8765/?v=0.032
