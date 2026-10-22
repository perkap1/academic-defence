# Academic Defence v0.031.7

PE Teacher can now be built on every build slot on all five maps. Removed road-distance and art-corridor restrictions. Controller and menu share the slot-ownership validation; occupied slots, insufficient KP and blocked sites still use existing construction rules.

No changes to tower cost, attack range, damage, rolling distance, projectiles, upgrades or tunnel behavior.

Test-driven verification: the updated all-slot test failed against the old restriction (57 failures), then passed with the implementation (588 checks). Six relevant suites passed with 925 checks total, covering every slot, exact build charge, duplicate purchases, foreign slots, insufficient funds, clearing, upgrades, refunds, medicine-ball direction and tunnel interactions.

GitHub publishing runs all 55 regression suites, then exports and deploys commit-specific game assets. Version: 0.031.7.
