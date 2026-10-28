# Elite pupils and temporary bosses implementation plan

**Goal:** Add one ranked replacement on elite waves and the last wave of each map without changing spawn totals, base type mix or routes.

**Architecture:** Cache rank and multiplier in each existing wave plan. Apply health scaling through existing student classes, and use a clothing palette shader that also respects the existing tunnel clip. Keep preview composition totals intact and add explicit rank details per entrance.

**Tech stack:** Godot 4.4 GDScript/canvas shaders, existing sprite atlases.

## Requirements and choices
- Every fifth wave has one elite: 2x at 5, 2.5x at 10, 3x at 15, 3.5x at 20, continuing by 0.5.
- Each map's final wave has one 5x boss instead of an elite if they coincide.
- Elite base type is chosen uniformly from types already present, then one matching record is replaced. No new types or entrances are introduced.
- Preferred temporary bosses follow the previous proposal: normal / PE / Bookworm / Snack / Pilot for maps 1–5; select an existing matching record. Keep all other type counts intact.
- Red clothes and E above elite bars; dark clothes and BOSS above boss bars. No new sprite models or animation frames.
- Dark-red warning only at the ranked enemy's cached entrance. Hover identifies the ranked pupil and multiplier without double-counting it.
- Confetti remains 25% of the ranked pupil's maximum, including self-healing clowns. Book shields do not grow back.
- No extra rewards, escape penalties, attack immunities, movement changes or boss abilities.
- Existing uncommitted v0.033 cartoon audio changes are preserved.

## Tasks
1. Write rank tests: all waves/maps retain totals and routes, one rank, cached randomness, exact health/healing and preview entrance. Run red.
2. Implement plan decoration and spawn configuration; scale each health implementation while preserving Snack's normalized Knowledge display and once-only eating mechanic.
3. Implement selective clothing palette plus E/BOSS labels and tunnel-compatible masking. Add dark-red entrance warning shader and ranked preview note.
4. Run focused tests, full regression suite, native visual board and web preview. Adjust test strategies only if intentional extra difficulty invalidates an old automated strategy; do not change requested multipliers.

## Review focus
- Mixed/one-route waves and finale batches: decoration must not move a record or reroll its route.
- Pilot, Clown and Snack custom health thresholds; fractional 2.5x multipliers and quarter-capacity healing.
- Snack's threshold, eating reset and healing accumulated during the break must scale together.
- Palette must leave skin, books, paper plane and UI intact, including every animation pose.
- Ranked units fully under bridge stay untargetable to ordinary towers; medicine ball and 25% confetti keep existing behavior.

## Completion evidence
- All four implementation tasks completed.
- 57 regression suites passed, including all five automated campaigns; 7723 rank checks passed.
- Front, side and back native visual boards and ranked warning panel inspected; selective clothing masks refined to preserve faces and books.
- Independent review found no important correctness findings.
- Web export succeeded; local browser visibly runs v0.034 at http://127.0.0.1:8765/?v=0.034.
