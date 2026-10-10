# v0.022 verification

New test_v022:95 checks for every boundary and intervening wave through20, distant-wave20% floor, varied base rewards, ten fractional rewards without cumulative loss, actual Normal/PE/Bookworm/Snack completion payouts and popups on all four maps, current/next HUD percentages, unchanged15KP Study Hall,35KP Improved Library and5KP/graduate Expanded Office capped50.

All37 gameplay suites are run in the GitHub workflow. The initial full run passed36 and exposed that the old fixed Map4 build strategy lost under the requested lower income. Its test-only strategy now covers the upper and lower entrances first, and seeds both the shared RNG and the separate lane RNG for reproducibility. It still uses the ordinary starting budget and actual purchases, completes all17 waves, preserves all victory/slot/progression assertions, and does not change production balance. Targeted rerun passed38 checks. Maps1,2,3 also complete their full wave simulations.

Read-only review found no payout, rounding or passive-income blockers. Its HUD ambiguity was resolved by labeling next-wave percentages during intermission. Godot-rendered screenshot confirms +6KP popup and60% status on Autumn Campus wave11. Web exported from the same project.

Local: http://127.0.0.1:8765/?v=0.022
