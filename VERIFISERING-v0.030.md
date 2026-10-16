# Academic Defence v0.030 – Class Clown

## Approved balance
- Ground student: speed85, maximum Knowledge120, base reward10KP before existing wave taper.
- Healing radius140, cast start every4active seconds, cast duration0.75s, one pulse at0.30s. Stops during cast and resumes same Path2D/progress. Prediction integrates casting stops and slow expiry.
- Each pulse removes15percent of each other active student's own maximum teaching capacity: Normal/PE/Bookworm15, Pilot22.5, Clown18, Snack60teachingpoints. Knowledge supports fractions so Pilot healing never loses halves to rounding.
- No self-healing, shield restoration, resurrection or recursive casts. Pilot retains Book-only vulnerability. Snack Break's existing one-time two-second meal and75percent own heal remain; concurrent confetti reduces its pending post-meal Knowledge as well.

## Waves
- Map4 waves13/14/15/16/17:1/1/2/2/3clowns.
- Map5 waves8–11:1each;12–15:2each;16–19:3each;20–22:4each.
- Replace evenly spaced Normal Students only. All original totals, special enemy counts, entrances, spawn intervals and final-wave batches retained.
- Maps1–3 have no clowns.

## Presentation
- Original attached sheets copied unchanged to assets/class_clown.
- Idle2, move4per direction, cast5, hit2, comic defeat5; fixed wheel/ground pivot. Source rows have different artwork sizes, normalized per animation state.
- Separate original confetti sheet supplies6pulse frames. Green+15percent only appears for actually healed pupils.
- Wave Warning includes exact Class Clown counts per entrance. New16x16thumbnail is derived in Godot from the supplied sprite with nearest filtering; existing six mini-icons unchanged.

## Verification
- test_class_clown: healing all existing kinds and other clowns, no self/chains, Snack overlap, Bookworm shields, Pilot restrictions, cast timing/movement, pause and game speed, one graduation and7KP reward atwave10.
- test_clown_waves: approved substitutions across all5maps, original totals and route mapping, exact preview.
- All50regression suites passed locally. Original normal-budget strategies finish Map4 with8Reputation andMap5 with4Reputation. The70 ClassClown unit checks and2437 wave-plan checks pass.
- Native visual checks inspect every animation plus full seven-row Wave Warning and confetti in-game.
- Independent read-only code review found no blocking issues; its Science prediction finding was fixed and reviewed again.
