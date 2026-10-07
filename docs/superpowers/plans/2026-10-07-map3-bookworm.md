# Map3 and Bookworm Implementation Plan

Use executing-plans inline and a fresh-context final review. User specification: latest chat prompt and three attached PNGs. User clarified 14 slots: 12 painted markers plus two extra suitable grass positions.

Architecture: extend existing map/student flows. Each map exposes live students and nearest road point; Map3 has two Path2Ds with identical merged suffix. Bookworm inherits student movement/slow/assistant/completion and overrides positive Knowledge hits to remove one shield. Godot atlases use supplied original sheets. Persistent progression unlocks Map3 after Map2 victory and remembers first Bookworm tutorial; script tests never write real player saves.

Constraints: do not change Maps1/2 geometry/combat/economy or wave mixes. No Aseprite. Map3 15 exact suggested waves; starts with 200KP and10Reputation. Two extra slots (1148,393),(1148,550), moved after visual inspection to clear the stone pillar. Calm pixel scaling, shared foot anchors, short0.45sec fall/reaction effect independent of unit motion.

- [ ] Add RED tests for Bookworm shield/movement/slow/completion and Map3 paths/slots/wave mixes/unlock.
- [ ] Add Bookworm atlas variant and shared hit reaction through existing Knowledge input; prove Golden/AoE/assistant compatibility.
- [ ] Implement two-path Map3,14slots,15waves and live-student/nearest-road accessors without changing old maps.
- [ ] Implement persistent Map3 unlock and one-time non-blocking tutorial; test both restart and old-map selection.
- [ ] Graphical/frame/path inspection, full regression and ordinary-budget Map3 win; independent final review.
- [ ] Export same Web game, update documentation and publish existing main/Pages; verify public startup/gameplay.

Progress ledger:
- Bookworm and Map3 initial RED observed (missing variants); GREEN:17 shield checks,64 Map3 checks.
- Progression initial RED observed (missing autoload); GREEN: victory unlock, real button state, one-time tutorial and isolated save/reload.
- Shared route access keeps old curve construction unchanged. Existing16-test suite:3,310 checks,0failures, including complete Maps1/2 rounds.
- Combat integration:17checks verify both entrances, Golden single-spend, one AoE shield each, slow through shields, assistant hold/ticks/release.
- Map3 ordinary-budget full15wave round:32checks,0failures;355students resolve exactly once,347graduates,2Reputation left.
- Graphical actual mouse input:74checks,0failures;14build slots open/build/select/sell, wave4 tutorial and all reaction frames. All72 Bookworm poses rendered and inspected.
- Ruling: standalone Bookworm scene retains the original student node hierarchy and inherits its script, avoiding PackedScene override double-initialization of the base slow-indicator resource (79 leaked resources in original inherited-scene attempt; clean after fix).
- Ruling: atlas column regions stop before colored sheet borders, found during graphical inspection.
- Fresh-context final review: no Critical/Important findings; final slot coordinates corrected in this plan. Web verification remains next.
