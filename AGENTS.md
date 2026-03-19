# Agent / maintainer notes

## After changing Instruqt or workshop bootstrap code

1. Commit on `main`.
2. From repo root run **`make publish`**:
   - validates both tracks (`instruqt/` and `instruqt/review-bomb-workshop-serverless/`)
   - `git push origin main`
   - `instruqt track push --force` for **review-bomb-workshop** and **review-bomb-workshop-serverless**
   - re-copies `instruqt/track-serverless.yml` → `review-bomb-workshop-serverless/track.yml` (CLI shortens the file on push)

Requires Git SSH/auth to `origin` and `instruqt auth login`.

See `instruqt/README.md` for track layout and checksum notes.
