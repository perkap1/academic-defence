# Verification v0.018

Blocked sites: fixed 3/9 on Map 1, 3/8 on Map 2, 5/14 on Map 3 and 5/14 on Map 4. Exact slot indices and categories are documented in README. The six requested variants are cropped from the supplied PNG, using matching 336x336 canvases, one fixed sprite origin, nearest filtering and no generated artwork. The optional cardboard/leaf-only alternatives are unused. The obstacle input rectangle covers the full art in addition to the existing circular slot.

Clearing costs 30/50/70 KP. Atomic clearing mutates state before changed notifications; repeated input cannot charge twice. Both manager and controller refuse construction while blocked. Clearing persists through tower sale and resets with a new scene attempt. Clear/cancel menu handles insufficient funds, live KP updates, Escape, pause and round completion.

Book upgrades changed from 80/130 to 100/150; Science from 100/150 to 120/170; Study Hall specialization from 120 to 140. Costs are static values and cannot accumulate on reload. Base building costs, income, combat stats, waves, enemy behavior, maps and routes are unchanged. Actual building investment drives 50% refunds, excluding clearing.

33 gameplay scripts pass. New blocked-site regression: 185 checks, zero failures, covering all maps/variants, hover texture and origin, direct construction rejection, exact payments, insufficient funds, duplicate calls, pause/end guards, cancel, sell/rebuild, restart and upgrade/specialization accounting. Existing tower unit fixtures explicitly remove blockers to isolate their combat/stat assertions. Full integration strategies instead pay real clearing costs with their ordinary 200 KP starting budget: all four maps win (Map 1:9, Map 2:8, Map 3:4, Map 4:3 Reputation remaining; random lanes may vary results).

Web export succeeded. Godot screenshots verified blockers and clearing panel on Autumn Campus. Browser test cleared the central stone site for70 (200 to130), built a120 KP assistant post, and sold it for60 (10 to70); the site remained clear. Original game behavior is retained. No Aseprite used.
