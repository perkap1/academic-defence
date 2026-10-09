# Verification v0.017

Autumn Campus uses the original supplied 1672x941 PNG without editing or scaling the source artwork. SHA256: 05A6D1D18F4E016BDC804DED6BEB1755CAE8EDDD4AA37EB90F06EEC868C5F34B.

There are 14 build slots: five above the upper road, four between roads and five below the lower road. Two independent curves retain their own entrances and exits. Geometry checks sample both centerlines and lane offsets up to 24 pixels against road colors. Visual Godot and browser checks confirm placement, sharp rendering and the existing HUD.

Exactly 17 waves: 3/9/15 use upper only, 6/12 lower only, all others both. The finale has three pulses with shields/tanks before faster students. Route notices disappear automatically. Existing tower, enemy and economy stats are unchanged. Map 3 remains initially available; completing it unlocks Map 4. Map 5 remains locked. Completion of Map 4 survives a save/load round trip.

All 32 gameplay test scripts pass. Map 4 geometry/waves/progression: 840 checks, zero failures. Both-route combat: 16 checks, zero failures, including Book, Science slow, assistant blocking, Snack recovery, Scholarship rewards and exit Reputation loss. Full-budget integration: 38 checks, zero failures; all 17 waves completed with four Reputation remaining and all 14 slots occupied. Randomized lanes can vary the final Reputation. Victory records level 4 completion.

Web export succeeded. Local browser checks covered opening Autumn Campus, building towers, starting a wave and the route notice. Debug route lines exist only in the visual test, not the production scene.
