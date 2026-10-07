# Academic Defence v0.012 — komisk Book Tower

Samme eksisterende Godot 4.4.1-prosjekt. Originale vedlagte PNG-er brukes direkte som atlases; ingen Aseprite eller sletting av tidligere assets.

- 3 356 headless-kontroller, 0 feil, fordelt på 22 tester. Tidligere visuelle forventninger for A/B/C og gammel tårn-idle er oppdatert til den uttrykkelig ønskede enkelt-frame-boka og nye idle/throw-poser. Treff, stats og spilleregler testes fortsatt.
- Ny comic-test ble først kjørt rød (manglet 12 nye frames), deretter grønn. Visuell kontroll avdekket at nivåtall lå under sprites; egen regresjonstest ble kjørt rød og fiksen verifisert grønn (LevelBadge over banneret).
- Alle 12 poser vist på Level 1, 2 og 3. Samme sprite-sheet, canvas, scale og fast nedre mursteinsbase på alle nivåer; gulltallene følger faktisk tower.level og ligger stabilt over det blå banneret.
- 15 grafiske kontroller med skjermbilder: 12 idle/kast-poser og tre informasjonspaneler.
- 54 grafiske kontroller med faktiske museklikk på bane 1 og 2: bygging, Level 1→2→3, riktige kostnader/stats, MAX LEVEL, disabled upgrade og salg/refund.
- Book Tower beholder cooldown, range, target, single-target-treff, Knowledge og Golden-regelen. Prosjektilets ene sprite spinner rundt midten i Godot, med nearest-filter. Bookworm, Blackboard, assistants og økonomibygninger består regresjonstestene.
- Hele bane 1, 2 og 3 kjørt med vanlig budsjett og alle bølger. Bookworm mister én bok per vanlig eller Golden Knowledge-event.
- Web-export: exit 0, index.html med tilhørende JS/WASM/PCK. Samme kildeprosjekt brukes i den eksisterende automatiske GitHub Pages-workflowen.
