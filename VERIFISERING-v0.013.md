# v0.013 — Science Tower

Blackboard Tower is visually replaced by the supplied Overenthusiastic Science Teacher. The existing `blackboard` identifier and scene are retained for compatibility. No maps, paths, wave tables or other tower balance changed. Aseprite was not used; original PNGs remain intact and Godot AtlasTexture regions supply the frames.

- Five calm idle poses at 3 FPS; four experiment poses over 0.4 seconds.
- Same art, scale and origin at all levels; stable lower base and gold 1/2/3 badge.
- Four green/purple orb frames and five science cloud frames. Cosmetic travel lasts 0.16 seconds, followed by a 0.45-second impact animation at the selected area. Knowledge/slow still apply as the original immediate attack event, preserving targeting, cooldown and gameplay timing; the cloud is not a persistent damaging zone.
- Science bubbles replace the old wet/drip visuals on affected students and disappear when slow expires.
- Existing costs: build 100, upgrades 100/150; 50% total-investment sale refund.
- Existing Knowledge 15/19/22, AoE radius 105/126/147, attack interval 1.3 seconds, range 225, slow 30/30/40% and duration 2/2.5/2.5 seconds.

## Verification

The new test failed on missing science frames, level badge and display name before implementation, then passed with 51 checks.

All 23 headless regression scripts passed: **3413 checks, 0 failures**. Coverage includes normal and PE students, every upgrade level, slow refresh/expiry, Bookworm shield events, assistants, graduation, economy and complete rounds on all three maps.

Graphical checks: **21 science captures + 54 mouse-driven upgrade/UI checks**, all passed. Inspected every tower pose, animated orb, cloud and level banner. Comparing the lower base crop across all nine poses found **0 changed pixels**. Nearest filtering is retained.

Godot Web export succeeded. The local browser loaded v0.013 and passed radial building and Level 1→2 upgrade checks; resources changed from 200→100→0 correctly, and the banner showed 19 Knowledge, 126 AoE radius, 30% slow for 2.5 seconds and a 100 KP sell refund. No warning/error entries appeared in that local session.
