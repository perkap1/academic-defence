# v0.029 – Ny bane 3

- Bruker vedlagte assets/map3.png uendret.
- Brukeren avklarte to innganger: begge fra venstre. Øvre vei går ut til høyre; nedre vei går under tunnelen og ut øverst. Toppen er utgang, ikke en tredje inngang.
- 16 synlige sirkler er build slots med eksisterende bygge-/salgs-/oppgraderingssystem. Eksisterende blocker-layout og ryddekostnader beholdt.
- Egne kurver følger hver vei. LowerPath ligger bak et AtlasTexture-utsnitt av originalbildets bro/tunnel; øvre vei går over broen. Ingen endring i kildebildet.
- Varselnavn UPPER LEFT PATH/LOWER LEFT PATH. Antall, typer og inngangsfordeling hentes fra eksisterende spawn-plan.
- Samme 15 waves og fiendetyper, inkludert Pilot og finale-reglene for13–15. Ingen endringer i økonomi, tårn eller elevstats.
- test_map3_replacement kontrollerer innganger fra venstre mot høyre, utgangene, tunnelpunktene og16slots.
- test_map3 beholder alle kontroller av eksisterende waves og fiendefordeling.
- test_map3_integration bruker plasseringer for det nye kartet og normal økonomi: vinner15waves,3Reputation,409fullførteelever,16tårn. Seed2903 for reproduserbar test.
- Rutene kontrollert med midlertidige linjer i native Godot. Linjene følger veiene og inngår ikke i web-build.
