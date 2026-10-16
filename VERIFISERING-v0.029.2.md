# v0.029.2 – Gradvis skjuling under broen

- Bakkeelevenes synlige piksler klippes mot broens tak (x850–1000, y335–450). Figuren forsvinner dermed gradvis bak buen og kommer gradvis frem på oversiden, uten blur eller endring i kartbildet.
- Targeting følger kroppens faktiske alpha-grenser, inkludert AtlasTexture-margin og sprite-transform. Deler av figuren utenfor taket betyr at eleven fortsatt kan treffes. Først når hele figuren er innenfor taket, skjules elev/UI og angrep blokkeres.
- Klippmaterialet brukes på figuren, Knowledge-bar, slow-indikator og skygge. Piloter og øvre rute er unntatt.
- Eksisterende beskyttelse mot treff som allerede er på vei og skjoldtap beholdes når kroppen er helt skjult.
- test_bridge_transition: over1200kontroller for alle5fiendetyper gjennom hele overgangen, pluss ekte Book Tower-skyting ved innpassering, fullt skjult, fremkomst og utenfor broen.
- test_bridge_cover, test_bookworm_combat, test_unit_layout, test_snack_combat, test_v019, test_v023, test_v026 og test_v027 bestod.
- Full native Godot-gjennomspilling av bane3:15waves,409fullførteelever,3Reputation igjen,32kontroller uten feil. Overgangene kontrollert visuelt med delvis skjulte bakkeelever og pilot over broen.
