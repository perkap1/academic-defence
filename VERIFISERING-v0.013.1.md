# v0.013.1 — Bookworms on Maps 1 and 2

Bookworms now replace some normal students from wave 4, preserving total counts, PE counts and spawn intervals. Map 1 Bookworm counts: 0/0/0/1/1/2/2. Map 2: 0/0/0/1/2/2/3/3/4/4/5/6. Map 3 is unchanged. The shared first-encounter tutorial works on every map.

The new spawn test failed before implementation and then passed with 114 checks. Six relevant spawn, full-round and combat regression scripts passed: **381 checks, 0 failures**. With normal starting budgets, Map 1 completed all 7 waves with 9 lives and Map 2 completed all 12 waves with 8 lives. All 80/218 students resolved exactly once. Bookworm shields and tower interactions remain unchanged.

Two older full-wave tests now remove the three book shields before using their final 100-Knowledge test hit. Successful Web export updates the existing local build.
