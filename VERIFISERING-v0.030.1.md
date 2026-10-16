# v0.030.1 – Tidligere og sterkere Class Clown

- Map3 wave3–8:1klovn hver;wave9–14:2hver;wave15:3. Tidligere kart har ingen klovner. Map4/5 beholder eksisterende antall og introduksjonswaves.
- Normal Students erstattes i de tidlige wavene. Map3-finalen13–15 har ingen Normal Students, så henholdsvis2/2/3Bookworms erstattes der. Fiendeantall, innganger, spawn-intervaller og puljer beholdes.
- Selve figuren økt25percent i alle animasjonsstater. Samme hjulpivot beholdes, og spawn bruker riktig størrelse umiddelbart. En test måler faktisk opaque kroppshøyde mot Normal Student.
- Heal-radius180(tidligere140),25percent(tidligere15) av hver mottakers eget maksimum. Cooldown4sekunder,cast0.75sekunder og enkeltpuls ved0.30sekunder beholdes.
- +25percent-indikator hentes fra faktisk heal-prosent.
- Bridge-cover/overgangstester inkluderer nå også klovnen, som følger de samme synlighets- og targetingreglene som andre bakkefiender på Map3.
- test_class_clown/test_clown_waves/test_map3/test_v023/test_v026/test_v027/test_bridge_cover/test_bridge_transition bestod.
- Ordinær budsjettstrategi fullfører Map3 med3Reputation ogMap4 med8Reputation. Map5 fullført med3Reputation.
- Native visuell kontroll av størrelse,25percent-puls og Map3wave3-preview. Uavhengig review fant ingen feil i wavefallback eller healing-popup.
