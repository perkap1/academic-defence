# GitHub Pages Implementation Plan

Goal: publish the existing Academic Defence v0.005 project unchanged.
Architecture: initialize Git in the existing source folder, keep all resources and export templates, build and test the same source in Actions, publish the Web artifact to Pages.
Tech stack: Godot 4.4.1, Git, GitHub Actions and Pages.
Spec: user request in this chat dated 2026-10-02.

- Verify project and absence of existing Git history.
- Add Godot ignore rules, README and tested export/deployment workflow.
- Create public perkap1/academic-defence repository and push main without force.
- Enable Pages using GitHub Actions and set homepage.
- Confirm CI tests/export/deployment and exercise the public game in a browser.

Constraints: preserve all gameplay/assets and desktop behavior; no project copy or history reset. Deploy only after tests and export pass.
