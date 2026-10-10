# v0.020 - verification

- 35 regression suites pass, including complete normal-budget Map 2 (12 waves), Map 3 (15) and Map 4 (17) simulations. Existing price/payout fixtures updated to the requested values.
- 71 targeted checks cover per-building records, actual/clamped Knowledge, Bookworm shields, Snack immunity/recovery, direct graduation once, Science casts and actual AoE impacts, both assistants' stops/teaching/time, lifetime/current-stage upgrade retention, Office actual graduation cap/reset, no duplicate reward across waves, income persistence through specialization, live Stats tab at pause and correct refunds/prices.
- Native screenshots inspected: Book total1500/current700 example, Scholarship total230/current140 example, current-wave cap, Office Info and Assistant table. Five rows fit inside a 224px Stats banner; Info remains168px. Sell and upgrade controls stay accessible.
- Independent code review found no blockers.
- Godot4.4.1 Web export succeeded. New animations/art, maps, waves, combat stats, clearing costs and progression rules were not changed.

Economy: Study15; Library30; Scholarship0base +5/graduate, max40/wave. Specialization140. Book upgrades100/200; Science120/220. Sale half actual investment, excluding clearing.

Statistics are per run. Snack Knowledge counts actual delivered teaching points (400 to graduate), not the normalized percentage bar. In-flight impacts count when they happen; combat values remain those at launch. Sold-building records are not transferred to a new building on the same slot.
