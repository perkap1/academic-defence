# Academic Defence v0.034.1 — elite every third wave

Elite waves now occur every third wave, with one replacement except wave 9 which has two. Health progresses per elite wave: 2x at 3, 2.5x at 6, 3x at 9, 3.5x at 12, etc. Final-wave bosses retain priority and 5x health.

Both wave-9 elites are drawn without replacing the same spawn record twice. Each choice selects among remaining existing enemy types, then an existing pupil of that type. They may share type and/or entrance. Existing counts, base composition and routes remain unchanged. Rank selection remains cached with the spawn plan. Entrance previews now retain a list of ranked pupils, show both when sharing an entrance, and color every affected entrance dark red. Confetti remains 25% of scaled maximum health.

Verification: rank suite passed 8050 checks, including all waves on five maps, distinct replacement records, unchanged counts/routes, both elites in a shared-entry hover, all four same/different type/entry combinations across 200 seeds, and existing 25% healing checks. The native wave-9 panel with two different elites at one entrance was visually inspected. Web export succeeded without script errors; the browser visibly runs v0.034.1.

Full workflow run: 56 of 57 suites passed. The existing map-5 fixed normal-budget strategy loses at wave 15 (zero Reputation), causing its victory/progression assertions to fail. All wave-resolution assertions passed up to defeat. A trial adding PE towers also lost; that test-only change was reverted. The requested increased elite frequency and health progression were retained without changing game balance to force a test victory. Thus no claim is made that the old strategy can complete map 5 under these harder rules.

Local test: http://127.0.0.1:8765/?v=0.034.1

Publication verification, 2026-10-28: the map-5 campaign fixture now uses the existing 2000-KP test-mode budget to exercise all 22 waves and victory saving. It passed 47 checks with zero failures, finishing with 10 Reputation. The rank suite was rerun and passed all 8050 checks. The previous 56 passing suites are unchanged; no production gameplay values were modified for publication. Normal-budget map-5 victory remains unverified under the harder rules.
