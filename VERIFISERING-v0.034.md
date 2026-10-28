# Academic Defence v0.034 — elites and temporary bosses

One existing spawn record becomes elite every fifth wave: 2x maximum health at wave 5, 2.5x at 10, 3x at 15, increasing by 0.5 each five waves. The base type is chosen randomly from the wave's existing types. The final wave of each map has one 5x boss, taking priority over an elite. Preferred boss types for maps 1–5 are Normal, PE, Bookworm, Snack and Pilot.

Counts, type composition, routes, rewards, speeds, shields and attacks remain unchanged. Rank selection is cached with the actual spawn plan. Elites have red clothes and E above the bar; bosses have dark clothes and BOSS. Only the ranked unit's entrance gets a dark-red warning; hover identifies its type and multiplier without adding it to the total twice.

Confetti heals 25% of scaled maximum health, including self-healing clowns. Snack's normalized Knowledge bar, eating thresholds and accumulated healing scale together. Tunnel clipping and ordinary targeting immunity remain intact; medicine balls retain tunnel damage.

Verification: all 57 workflow test suites passed, including full automated campaigns on all five maps. New rank suite: 7723 checks, zero failures. Existing completion fixtures now graduate scaled units using their actual capacity; campaign rank RNG is seeded for repeatable tests. Native rendered front/side/back boards and final-wave warning panel were inspected. Independent code review found no important correctness issues. Web export succeeded and browser visibly displays v0.034.

Prior approved v0.033 cartoon audio changes are preserved. No GitHub publication was performed in this task.

Local test: http://127.0.0.1:8765/?v=0.034
