# v0.036.2 — immediate upgrade arrow

Removed the upgrade confirmation dialog and its pending-slot state. Every enabled green upgrade arrow now calls the existing upgrade controller immediately, including PE Teacher, Library and Scholarship Office. Book and Science retain their existing immediate behavior. Disabled/hidden arrows do nothing; the controller still enforces affordability, maximum level, paused/finished state and valid selection. Prices, stats, positions and specialization choices are unchanged.

Verified PE Teacher (568 checks), economy/upgrades and animation compatibility (V021: 70), upgrades (107), presentation (122), economy (92) and building refresh (67), all zero failures. Updated the legacy V021 idle expectation to the previously requested 1.5 FPS. Web export completed without script errors.

Local test: http://127.0.0.1:8765/?v=0.036.2
