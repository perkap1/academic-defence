# v0.026 verification

Scope: read-only planning UI at entrances. No changes to wave arrays, counts, intervals, routes, enemy stats, rewards or building stats.

- WaveManager get_spawn_kind/get_spawn_route accept an optional wave argument; omitted arguments retain current spawning behavior. get_next_wave_preview aggregates every spawn event for the next wave by actual route and kind. It never mutates current wave or RNG.
- Shared WavePreview Control is attached to the existing HUD. Golden rectangle-drawn pixel icons use48px hit targets; panels reuse the existing UI skin and enemy sprites.
- Entrance placement uses visible path starts, normal offsets, road/slot clearance and screen bounds. Icons are outside all build-slot hit areas on all maps.
- Mouse enter/leave opens/closes; touch pins, second touch or outside input closes. Native engine input tests cover hover, leave and first/second tap. Main input ignores preview-icon clicks so selected towers and assistant rally points stay unchanged.
- Icons clear synchronously on wave start and game end; next icons appear during intermission, including initial wave1; none after the final wave. Pause hides previews.
- tests/test_v026.gd:4180 checks pass, covering every wave on allfive maps, exact per-entry rows/totals, RNG/state purity, panel bounds, build-slot clearance, selection/rally preservation and native interaction.
- Native visual screenshot inspected with allfive enemy types on Map5wave22, including later spawn groups.

The regression workflow runs42 suites, including ordinary-budget full runs on allfive maps.

Final validation: all42 regression suites passed locally. Export succeeded. Local Web v0.026 was opened on Map5 and its entrance A preview displayed Normal6 + PE2 =8 before wave1.
