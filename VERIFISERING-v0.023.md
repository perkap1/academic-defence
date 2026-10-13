# v0.023 verification

Scope: Paper Plane Pilot, Map 3 finale, gradual air waves on Map 4. No changes to Map 1/2 compositions, tower prices, tower stats, maps or building slots.

- New regression test covers attack eligibility, 150 Knowledge, 102 speed, direct unsourced damage rejection, assistant reservation/slow immunity, all 27 frame canvases, exact wave compositions and final route quotas.
- Real Science impact cannot affect air units; real Book projectiles graduate them with 150 Knowledge and one graduation recorded. Wave 11 pays 6 KP, preserving the existing reward model.
- Map 3 ordinary-budget integration completed all 15 waves, including 77-enemy finale, with 3 Reputation remaining.
- Map 4 first air unit moved from wave 5 to wave 7 after ordinary-budget testing showed insufficient preparation time. Existing 17 waves and route rules remain intact.
- Original supplied PNG is preserved. Connected alpha components isolate poses that overlap rectangular column boundaries. All extracted poses use a fixed 240x270 canvas and fixed source scale.
- Visual review found and corrected crop-edge contamination, header remnants, clipped defeat goggles and finale-notice encoding.
- The supplied sheet contains three defeat poses per direction, which matches the requested 3–4 frames.

Run automated tests with Godot 4.4.1 using the test list in `.github/workflows/pages.yml`.

Final validation: all 38 regression suites passed (Map 4 rerun after moving its first pilot to wave 7). Map 4 ordinary-budget integration completed 17 waves with 1 Reputation remaining. Web export succeeded and the local browser displayed v0.023.
