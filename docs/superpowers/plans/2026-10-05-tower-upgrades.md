# Tower upgrades v1 Implementation Plan

> Execute inline with test-driven development and final independent review.

Goal: Add levels1–3 for existing Book/Blackboard instances plus a compact bottom banner; keep Assistant functionality and its existing panel untouched. Preserve maps, waterfalls, waves and Level1 balance.

- [x] Write failing tests for purchase/ownership/funds/MAX, stats, investment refund, position/cooldown preservation, Golden Letters and variable nonstacking slow.
- [x] Extract user art using Aseprite into common180×188 canvases, aligned center/base; retain original sheets. Use idle frames and active frame per level.
- [x] Add tower level/stat API and manager transaction; preserve the actual node, cooldown and attack state. Book3 every fifth shot after reaching3 is golden,2× Knowledge. Blackboard radius126/147,Knowledge19/22,slow30%/40%,2.5sec. Keep Book1 stats260/20/1.0 and Blackboard1 stats225/15/1.3/radius105/slow30%2sec.
- [x] Generalize student slow strength preserving existing movement/hold logic, strongest current slow with refreshed duration; reset on expiry. Keep effects.
- [x] Add fixed bottom banner for Book/Blackboard with live stats, icon, green pixel arrow, visible cost/MAX and sell refund. Preserve separate Assistant panel.
- [x] Test real input upgrade/disabled/MAX/deselect/sell and graphics on both maps; run all existing tests and independent review.
- [x] Export same project to existing local Web folder and verify browser test link. No GitHub push requested.

Ruling: widen upgraded canvases to 180×188 to retain Blackboard flags/glow; keep base centred and the same vertical origin. No gameplay effect.
Review: independent reviewer found lower banner text overlapping frame. Added graphical layout regression: 8 failures before correction, 0 after. All 54 graphical upgrade checks passed. No other functional findings.
Validation: 107 upgrade/attack/slow/ownership checks plus 1,259 existing regression checks passed, including complete rounds on both maps. Web export succeeded.
