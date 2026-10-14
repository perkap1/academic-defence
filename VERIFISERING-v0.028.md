# v0.028 – Bane 2 med Left Path og Top Path

- Kartvedlegget kopiert direkte til assets/map2.png uten bildeendringer.
- Åtte eksisterende sirkelposisjoner og blocker-layout/kostnader beholdt; markeringene har samme koordinater i det nye kartet.
- Ny TopPath starter ved x760 over bildekanten. Begge rutene deler nøyaktig samme kurvesegmenter fra (768,279) til utgangen.
- Waves 1/5 bruker Left; 3/6/9 bruker Top; øvrige alternerer mellom begge. Wave12 har tre puljer med pause etter spawn12 og24. Eksisterende antall, fiendetyper, intervaller og økonomi beholdt. Ingen piloter.
- Varselnavn LEFT PATH/TOP PATH og faktiske planlagte elevantall. Informasjonsbanner flyttet til høyre for å holde Top-varselet synlig.
- Nye tester kontrollerer innganger for alle12waves, samme utgang/felles kurvesegmenter, kortere TopPath, og Snack som spiser og fortsetter på samme rute.
- test_map2_integration: normalbudsjettstrategi vinner12waves med8Reputation, alleelever regnskapsføres, ingen tårn taper som forventet.
- test_v003, test_v026, test_v027, test_waterfall, test_blocked_sites og test_snack_combat består.
- Native rutekart kontrollert visuelt med midlertidige kurvelinjer; debuglinjer inngår ikke i spillet.
