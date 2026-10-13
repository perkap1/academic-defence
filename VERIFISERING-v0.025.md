# v0.025 — The Final Exam verification

## Scope and map

Original winter PNG copied byte-for-byte; SHA256 F09E13D243F9C3CB14B7AB7360039DF9787B1F40BB5144D325533C75EA8C5F91 matches the attachment. 1672x941, nearest filtering, existing 190px HUD offset.

21 existing platform centers; 11 open. Fixed blocked indices (zero-based):
- School / 30 KP: 0, 5, 15, 19.
- Wood / 50 KP: 8, 11, 20.
- Stone / 70 KP: 7, 10, 17.

Four Path2D routes reuse existing movement, lane variation, tower targeting and assistant rally logic. A/B/C share the exact final point sequence into (1508,311); D ends independently at (1450,652). D never joins the other routes. Map5-only curve metadata limits lane offsets to16 pixels; other maps retain24.

## Waves and economy

22 wave mixes and entry cycles are authored in scripts/final_exam_waves.gd. Wave1 A, wave2 A+B, wave3 A+C, wave4 B+D; later waves rotate fronts and waves19–22 use allfour. Wave22 contains20 Normal,24 PE,30 Bookworm,16 Snack,18 Pilot:108 total, with pauses after28,56,84 spawns. No boss.

Shared completion flow uses5KP base fromwave4 for Normal, PE (both variants), Bookworm. Snack/Pilot base10 unchanged. Percentage model, accumulated rounding,45KP wave bonus and economy building income unchanged.

## Validation

- tests/test_v025.gd:1073 checks, zero failures: road pixels at center/extreme lanes,21 platform centers, exact blockers/costs,22 mixes, routes, unlock and best-star save/reload.
- tests/test_v024.gd:125 actual completion/reward checks across allfive maps, including wave3/4 boundary, later percentages and unchanged Snack/Pilot rewards.
- Map5 ordinary-budget test completes all22 waves using actual purchases, clearing, upgrades, combat and200 startingKP. Final geometry run:4 Reputation,952 graduates,6 escapes; all958 students accounted for once. Victory saves level5.
- Visual route overlay checked against original roads. Instruction panel moved to the existing right-side layout to avoid covering the upper platforms.
- Existing Map4 strategy requires adjustment after the intentional shared-income reduction; production Map4 waves, map and tower stats are not altered.

Final Map4 ordinary-budget strategy starts with Books at7 and8, then expands; it completes17waves with8 Reputation. All41 regression suites pass locally, with Map4 rerun after its test-only strategy adjustment. No funds or stats are injected into either ordinary-budget integration test.
