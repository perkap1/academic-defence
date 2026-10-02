# Teaching Assistant Post implementation plan

Goal: add a stall/teaching tower to the existing game, preserving other towers and waves.
Architecture: Assistant Post owns two assistant nodes. Students reserve one teacher and stop only during teaching. Assistants approach locally, teach for three seconds at 5 Knowledge/sec, release, return, then cool down. Student completion and tower tree exit release ownership synchronously. Rally points snap to the route within tower range; selected posts expose manual relocation.
Tech stack: existing Godot 4.4.1 GDScript, provided PNG sprite sheets.

- [x] Add behavior tests and observe failure before implementation.
- [x] Extract supplied art with equal canvases/foot pivots; implement post, assistants and exclusive student ownership.
- [x] Integrate cost120/refund60, selection, rally and third radial choice.
- [x] Verify simultaneous students, third-student pass-through, timings, PE variants, completion, sale, pause and regression tests.
- [x] Independently review, export local Web and verify browser. Deliver local test link.

Use original project folder. Do not push or deploy this new version unless requested. Keep previous public v0.005 intact.
