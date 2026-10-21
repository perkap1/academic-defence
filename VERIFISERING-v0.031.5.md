# Academic Defence v0.031.5

- Normal start: 300 KP on all five maps. Test mode remains 2000 KP.
- PE Teacher levels 1/2/3: damage 50/65/80; cast interval 3.80/3.70/3.60 seconds; roll distance 240/300/360.
- Book Tower: build 90 KP; upgrade to level 2 costs 110; upgrade to level 3 costs 250.
- Science Tower: build 120 KP; upgrade to level 2 costs 150; upgrade to level 3 costs 280.
- Study Hall: build 50 KP. Existing income and specialization prices unchanged.
- Menus, affordability checks, invested costs and 50% sale refunds follow the updated prices.

Verified all 55 regression suites. Historical price assertions were updated; the map 5 test now consults actual build costs before paying to clear sites. Full map 5 campaign wins all 22 waves with the regular budget (4 reputation remaining), without changing game balance beyond the requested values. Web export completed without errors; checked version, 300 starting KP and menu prices visually.

Local test: http://127.0.0.1:8765/?v=0.031.5
