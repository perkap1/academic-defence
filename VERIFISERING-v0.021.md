# v0.021 verification

The new test_v021 suite exercises actual purchases and graduation events: branch prices, confirmation/cancel, affordability, one-time upgrades, Library income35, Office cap40->50 mid-wave, no base payout, per-student5, retained wave earnings, total/current-stage statistics without duplicate waves, wave reset, refunds125/150, Book L3 cost220/refund195, Science L3 cost250/refund235, all eight pointing directions at6FPS and economy/Desk idle at3FPS.

The full GitHub workflow runs36 gameplay suites, including four complete map wave integrations. Existing balance fixtures were updated for the new requested prices, preserving their behavioral assertions.

Godot-rendered visual captures inspect both gold building banners and portraits, Library/Office idle and active frames, max-level buttons, statistics and confirmation. Both sprite layers preserve original textures and pivots; the shader recolors only central blue banner cloth. Review found a description overflow which was corrected by using the existing extra-information column.

Web build is exported from the same Godot project. Local test: http://127.0.0.1:8765/?v=0.021
