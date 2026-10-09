# v0.019 verification

- All 33 existing regression suites passed; old static AoE fixtures now explicitly wait for landing. Full Map 1-4 wave simulations passed.
- 183 new checks passed: rating thresholds against actual starting Reputation, legacy save migration, best-score retention, unlocks, fixed route/lane prediction, all Science levels on both Map 3/4 routes, no damage before landing, single impact, target deletion/diversion, actual neighbors at landing, expiry/refresh/source distinction on all enemies, Bookworm shields and Snack immunity, real pause/double-speed clocks, result cleanup, sequential star pop final textures.
- Native rendered screenshots inspected: World Map 3/2/1/0 ratings, two-star Victory and Reputation, arc apex, ground impact. Nearest-neighbor supplied art used.
- Godot 4.4.1 Web export succeeded; local browser smoke test.
- No tower balance, wave, economy, clearing-cost, route or unlock changes.
