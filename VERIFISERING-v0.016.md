# Verification v0.016

Snack Monster has 2 idle, 4 walk and 4 eat frames in each of three directions. Left is mirrored for right. Frames share a fixed 180x240 canvas and foot anchor, nearest filtering and approximately 130% normal height. Speed is 59.5 versus 85; four teaching points produce one Knowledge percent, preserving fractional progress in the bar.

At the first hit crossing 50% Knowledge, eating starts immediately, including overshooting hits. All teaching, slow, wet effects, reservations and completion are rejected centrally during eating. Existing assistants release the student, Book/Science/assistants skip him, and in-flight books disappear harmlessly. After two active seconds Knowledge becomes exactly 25%. A permanent used flag prevents a second break. Progress, route, lane and facing are retained; pause stops the timer.

Snack counts: Map 2 [0,0,0,0,1,1,1,1,2,2,3,3]; Map 3 [0,0,0,1,1,1,2,2,2,2,3,3,3,4,4]. Existing normal/PE/Bookworm counts remain. Wave totals remain 12 and 15. All prior tower stats and economy remain unchanged.

29 gameplay test scripts pass. New Snack test: 151 checks, 0 failures; combat test: 12 checks, 0 failures. Tests cover threshold overshoot, central immunity, assistant release/reacquisition, alternate targets, AoE neighbors, in-flight golden books, paused timing, both routes, one-time healing, graduation rewards and exact wave composition. Map 2 budget strategy wins with 8 Reputation remaining; Map 3 wins with 5. Existing Bookworm and progression tests pass. Visual frame grid and actual Map 2/3 screenshots checked; Web build exported successfully.
